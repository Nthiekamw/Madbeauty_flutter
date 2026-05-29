import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/errors/supabase_service_exception.dart';
import '../../../core/models/domain/booking/reservation.dart';
import '../../../core/models/domain/serialization/supabase_domain_codec.dart';
import '../../../features/booking/logic/booking_create_failure.dart';
import '../../../features/booking/models/client_reservation_summary.dart';
import '../../../features/prestataire/models/prestataire_analytics_reservation.dart';
import '../../../features/prestataire/models/prestataire_reservation_item.dart';
import '../../../core/config/app_config.dart';
import '../../stripe/stripe_booking_payment_service.dart';
import '../../stripe/stripe_service.dart';
import '../profile/profile_service.dart';

class BookingService {
  BookingService(this._client, this._profileService);

  final SupabaseClient _client;
  final ProfileService? _profileService;

  /// Alias demandé dans le domaine fonctionnel (« booking » vs table `reservations`).
  ///
  /// [clientProfileId], s’il est fourni, doit correspondre au [client_profiles]
  /// de la session ou une [BookingForbiddenLookupFailure] est levée.
  Future<Reservation> create({
    required String prestataireId,
    required String serviceId,
    required DateTime dateHeure,
    String? notesClient,
    String? clientProfileId,
  }) async {
    return SupabaseErrorHandler.run(
      operation: 'booking.create',
      action: () async {
        final clientId = await _requireClientId();
        if (clientProfileId != null &&
            clientProfileId.trim().isNotEmpty &&
            clientProfileId != clientId) {
          throw const BookingForbiddenLookupFailure();
        }

        await _rejectIfBookingOwnPrestataire(prestataireId);

        final localSlot = _startOfMinuteLocal(dateHeure);
        final capacity = await _slotCapacityFor(prestataireId, localSlot);
        final bookedCount = await _activeReservationsCountAtSlot(
          prestataireId: prestataireId,
          at: localSlot,
        );
        if (bookedCount >= capacity) {
          throw const BookingSlotTakenFailure();
        }

        final payload = <String, dynamic>{
          'client_id': clientId,
          'prestataire_id': prestataireId,
          'service_id': serviceId,
          'date_heure': localSlot.toUtc().toIso8601String(),
          'statut': 'en_attente',
          if (notesClient != null && notesClient.trim().isNotEmpty)
            'notes_client': notesClient.trim(),
        };

        try {
          final response = await _client
              .from('reservations')
              .insert(payload)
              .select()
              .single();

          return SupabaseDomainCodec.reservation(
            Map<String, dynamic>.from(response),
          );
        } on SupabaseServiceException catch (e) {
          if (e.code == '23505') throw const BookingSlotTakenFailure();
          rethrow;
        }
      },
    );
  }

  Future<void> cancel(String bookingId) async {
    await cancelClientReservation(bookingId);
  }

  /// Refus prestataire : en attente → annulée (+ motif optionnel).
  Future<void> rejectByPrestataire(
    String bookingId, {
    String? reason,
  }) async {
    await SupabaseErrorHandler.run(
      operation: 'booking.rejectByPrestataire',
      action: () async {
        await _requirePrestataireId();

        final payload = <String, dynamic>{'statut': 'annulee'};
        final trimmed = reason?.trim();
        if (trimmed != null && trimmed.isNotEmpty) {
          payload['notes_prestataire'] = trimmed;
        }

        final updated = await _client
            .from('reservations')
            .update(payload)
            .eq('id', bookingId)
            .eq('statut', 'en_attente')
            .select('id');

        final got = updated as List<dynamic>;
        if (got.isNotEmpty) return;

        final snapshot = await _client
            .from('reservations')
            .select('statut')
            .eq('id', bookingId)
            .maybeSingle();

        if (snapshot == null) {
          throw AppFailure(DiscBk.errResMissing);
        }
        final raw = snapshot['statut'];
        final s =
            raw is String ? raw.trim().toLowerCase().replaceAll('é', 'e') : '';
        if (const {'annulee', 'cancelled', 'canceled'}.contains(s)) return;

        throw AppFailure(DiscBk.errResBadState);
      },
    );
  }

  Future<void> cancelClientReservation(String reservationId) async {
    await SupabaseErrorHandler.run(
      operation: 'booking.cancelClientReservation',
      action: () async {
        final clientId = await _requireClientId();
        await _client
            .from('reservations')
            .update({'statut': 'annulee'})
            .eq('id', reservationId)
            .eq('client_id', clientId);
      },
    );
  }

  /// Ramène la réservation en attente → « confirmée » (prestataire connecté uniquement).
  Future<void> confirm(String bookingId) async {
    await SupabaseErrorHandler.run(
      operation: 'booking.confirm',
      action: () async {
        await _requirePrestataireId();

        final updated = await _client
            .from('reservations')
            .update({'statut': 'confirmee'})
            .eq('id', bookingId)
            .eq('statut', 'en_attente')
            .select('id');

        final got = updated as List<dynamic>;
        if (got.isNotEmpty) return;

        final snapshot = await _client
            .from('reservations')
            .select('statut')
            .eq('id', bookingId)
            .maybeSingle();

        if (snapshot == null) {
          throw AppFailure(DiscBk.errResMissing);
        }
        final raw = snapshot['statut'];
        final s =
            raw is String ? raw.trim().toLowerCase().replaceAll('é', 'e') : '';
        if (const {'confirmee', 'confirmed'}.contains(s)) return;

        throw AppFailure(
          DiscBk.errResBadState,
        );
      },
    );
  }

  /// « Réalisée / terminée » pour le prestataire (confirmée uniquement dans le flux nominal).
  Future<void> markAsDone(String bookingId) async {
    await SupabaseErrorHandler.run(
      operation: 'booking.markAsDone',
      action: () async {
        await _requirePrestataireId();

        final updated = await _client
            .from('reservations')
            .update({'statut': 'terminee'})
            .eq('id', bookingId)
            .eq('statut', 'confirmee')
            .select('id');

        final got = updated as List<dynamic>;
        if (got.isNotEmpty) {
          await _captureStripePaymentIfNeeded(bookingId);
          return;
        }

        final snapshot = await _client
            .from('reservations')
            .select('statut')
            .eq('id', bookingId)
            .maybeSingle();

        if (snapshot == null) {
          throw AppFailure(DiscBk.errResMissing);
        }
        final raw = snapshot['statut'];
        final s =
            raw is String ? raw.trim().toLowerCase().replaceAll('é', 'e') : '';
        if (const {'terminee', 'done', 'completed'}.contains(s)) {
          await _captureStripePaymentIfNeeded(bookingId);
          return;
        }

        throw AppFailure(
          DiscBk.errResBadState,
        );
      },
    );
  }

  Future<void> _captureStripePaymentIfNeeded(String bookingId) async {
    if (!StripeService.isConfigured || !AppConfig.hasSupabase) return;
    try {
      await StripeBookingPaymentService(_client)
          .capturePaymentForReservation(bookingId);
    } catch (_) {
      // La réservation reste terminée ; la capture pourra être relancée côté serveur.
    }
  }

  Future<List<Reservation>> getByClient(String clientId) async {
    return SupabaseErrorHandler.run(
      operation: 'booking.getByClient',
      action: () async {
        final ownId = await _requireClientId();
        if (clientId != ownId) {
          throw const BookingForbiddenLookupFailure();
        }

        final response = await _client
            .from('reservations')
            .select()
            .eq('client_id', clientId)
            .order('date_heure', ascending: false);

        return _decodeReservationRows(response);
      },
    );
  }

  Future<List<Reservation>> getByPrestataire(String prestataireId) async {
    return SupabaseErrorHandler.run(
      operation: 'booking.getByPrestataire',
      action: () async {
        final ownId = await _requirePrestataireId();
        if (prestataireId != ownId) {
          throw const BookingForbiddenLookupFailure();
        }

        final response = await _client
            .from('reservations')
            .select()
            .eq('prestataire_id', prestataireId)
            .order('date_heure', ascending: false);

        return _decodeReservationRows(response);
      },
    );
  }

  Future<Reservation?> getById(String id) async {
    return SupabaseErrorHandler.run(
      operation: 'booking.getById',
      action: () async {
        final response = await _client
            .from('reservations')
            .select()
            .eq('id', id)
            .maybeSingle();
        if (response == null) return null;
        return SupabaseDomainCodec.reservation(
          Map<String, dynamic>.from(response),
        );
      },
    );
  }

  /// Réservations sur une plage (analytics : CA, conversion, occupation).
  Future<List<PrestataireAnalyticsReservation>>
      listAnalyticsForCurrentPrestataire({
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    return SupabaseErrorHandler.run(
      operation: 'booking.listAnalyticsForCurrentPrestataire',
      action: () async {
        final prestataireId = await _requirePrestataireId();
        final response = await _client
            .from('reservations')
            .select(
              'date_heure, statut, amount_cents, payment_status, '
              'services_beaute(prix)',
            )
            .eq('prestataire_id', prestataireId)
            .gte('date_heure', rangeStart.toUtc().toIso8601String())
            .lt('date_heure', rangeEnd.toUtc().toIso8601String())
            .order('date_heure', ascending: true);

        return (response as List<dynamic>).map((raw) {
          final map = Map<String, dynamic>.from(raw as Map);
          final service = map['services_beaute'];
          final prix = service is Map
              ? (service['prix'] as num?)?.toDouble() ?? 0
              : 0.0;
          return PrestataireAnalyticsReservation(
            dateHeure: DateTime.parse(map['date_heure'] as String).toLocal(),
            statut: map['statut'] as String? ?? '',
            amountCents: (map['amount_cents'] as num?)?.toInt(),
            paymentStatus: map['payment_status'] as String?,
            servicePriceEur: prix,
          );
        }).toList();
      },
    );
  }

  Future<List<PrestataireReservationItem>> listForCurrentPrestataire() async {
    return SupabaseErrorHandler.run(
      operation: 'booking.listForCurrentPrestataire',
      action: () async {
        final prestataireId = await _requirePrestataireId();
        final response = await _client
            .from('reservations')
            .select(
              'id, date_heure, statut, client_id, notes_client, notes_prestataire, '
              'services_beaute(nom), client_profiles(user_id)',
            )
            .eq('prestataire_id', prestataireId)
            .order('date_heure', ascending: true);

        final rows = response as List<dynamic>;
        if (rows.isEmpty) return const [];

        final items = <PrestataireReservationItem>[];
        final userIds = <String>[];

        for (final raw in rows) {
          final map = Map<String, dynamic>.from(raw as Map);
          final client = map['client_profiles'];
          final userId =
              client is Map ? client['user_id'] as String? : null;
          if (userId != null && userId.isNotEmpty) userIds.add(userId);

          final service = map['services_beaute'];
          items.add(
            PrestataireReservationItem(
              id: map['id'] as String,
              dateHeure: DateTime.parse(
                map['date_heure'] as String,
              ).toLocal(),
              statut: map['statut'] as String,
              serviceName: service is Map
                  ? (service['nom'] as String?)?.trim() ?? ''
                  : '',
              clientName: '',
              clientId: map['client_id'] as String?,
              notesClient: map['notes_client'] as String?,
              notesPrestataire: map['notes_prestataire'] as String?,
            ),
          );
        }

        final profileSvc = _profileService;
        if (profileSvc == null || userIds.isEmpty) {
          return items
              .map(
                (e) => PrestataireReservationItem(
                  id: e.id,
                  dateHeure: e.dateHeure,
                  statut: e.statut,
                  serviceName: e.serviceName.isEmpty
                      ? DiscPrestaDash.unknownService
                      : e.serviceName,
                  clientName: DiscPrestaDash.unknownClient,
                  clientId: e.clientId,
                  notesClient: e.notesClient,
                  notesPrestataire: e.notesPrestataire,
                ),
              )
              .toList();
        }

        final profileMap = await profileSvc.getByUserIds(userIds.toSet().toList());
        return List.generate(items.length, (i) {
          final item = items[i];
          final map = Map<String, dynamic>.from(rows[i] as Map);
          final client = map['client_profiles'];
          final userId =
              client is Map ? client['user_id'] as String? : null;
          final profile = userId != null ? profileMap[userId] : null;
          final parts = [
            profile?.prenom?.trim(),
            profile?.nom?.trim(),
          ].where((p) => p != null && p.isNotEmpty).cast<String>();
          final clientName = parts.isEmpty
              ? DiscPrestaDash.unknownClient
              : parts.join(' ');
          return PrestataireReservationItem(
            id: item.id,
            dateHeure: item.dateHeure,
            statut: item.statut,
            serviceName: item.serviceName.isEmpty
                ? DiscPrestaDash.unknownService
                : item.serviceName,
            clientName: clientName,
            clientId: item.clientId,
            notesClient: item.notesClient,
            notesPrestataire: item.notesPrestataire,
          );
        });
      },
    );
  }

  Future<int> countPendingForCurrentClient() async {
    return SupabaseErrorHandler.run(
      operation: 'booking.countPendingForCurrentClient',
      action: () async {
        final clientId = await _requireClientId();
        final response = await _client
            .from('reservations')
            .select('id')
            .eq('client_id', clientId)
            .eq('statut', 'en_attente');
        return (response as List<dynamic>).length;
      },
    );
  }

  Future<List<ClientReservationSummary>> listForCurrentClient() async {
    return SupabaseErrorHandler.run(
      operation: 'booking.listForCurrentClient',
      action: () async {
        final clientId = await _requireClientId();
        final response = await _client
            .from('reservations')
            .select(
              'id, date_heure, statut, prestataire_id, amount_cents, currency, '
              'paid_at, payment_status, services_beaute(nom), '
              'prestataire_profiles(id, nom_salon, user_id)',
            )
            .eq('client_id', clientId)
            .order('date_heure', ascending: false);

        final responseBis = response as List<dynamic>;
        final rows = <ClientReservationSummary>[];
        final uidList = <String>[];

        for (final raw in responseBis) {
          final map = Map<String, dynamic>.from(raw as Map);
          final service = map['services_beaute'];
          final prestataire = map['prestataire_profiles'];
          final userId =
              prestataire is Map ? prestataire['user_id'] as String? : null;
          if (userId != null && userId.isNotEmpty) uidList.add(userId);
          rows.add(
            _clientReservationSummaryFromRow(map, service, prestataire),
          );
        }

        final profileSvc = _profileService;
        if (profileSvc == null || rows.isEmpty) return rows;

        final unique = uidList.toSet().toList();
        if (unique.isEmpty) return rows;

        final profileMap = await profileSvc.getByUserIds(unique);
        return List.generate(rows.length, (i) {
          final summary = rows[i];
          final row = Map<String, dynamic>.from(responseBis[i] as Map);
          final prestataire = row['prestataire_profiles'];
          final uid = prestataire is Map
              ? prestataire['user_id'] as String?
              : null;
          final avatarUrl = uid != null ? profileMap[uid]?.avatarUrl : null;
          return ClientReservationSummary(
            id: summary.id,
            dateHeure: summary.dateHeure,
            statut: summary.statut,
            serviceName: summary.serviceName,
            prestataireId: summary.prestataireId,
            prestataireName: summary.prestataireName,
            prestataireAvatarUrl: avatarUrl?.trim().isNotEmpty == true
                ? avatarUrl!.trim()
                : null,
            amountCents: summary.amountCents,
            currency: summary.currency,
            paidAt: summary.paidAt,
            paymentStatus: summary.paymentStatus,
          );
        });
      },
    );
  }

  ClientReservationSummary _clientReservationSummaryFromRow(
    Map<String, dynamic> map,
    Object? service,
    Object? prestataire,
  ) {
    final paidRaw = map['paid_at'] as String?;
    return ClientReservationSummary(
      id: map['id'] as String,
      dateHeure: DateTime.parse(map['date_heure'] as String).toLocal(),
      statut: map['statut'] as String,
      serviceName: service is Map ? service['nom'] as String? : null,
      prestataireId: map['prestataire_id'] as String?,
      prestataireName:
          prestataire is Map ? prestataire['nom_salon'] as String? : null,
      amountCents: (map['amount_cents'] as num?)?.toInt(),
      currency: map['currency'] as String?,
      paidAt: paidRaw != null ? DateTime.tryParse(paidRaw)?.toLocal() : null,
      paymentStatus: map['payment_status'] as String?,
    );
  }

  Future<void> _rejectIfBookingOwnPrestataire(String prestataireId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await _client
        .from('prestataire_profiles')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) return;

    final ownId = Map<String, dynamic>.from(response)['id'] as String?;
    if (ownId != null && ownId == prestataireId.trim()) {
      throw const BookingCannotReserveOwnServiceFailure();
    }
  }

  Future<int> _slotCapacityFor(String prestataireId, DateTime at) async {
    final local = at.toLocal();
    final pgDow = local.weekday % 7;
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    final timeText = '$hh:$mm:00';

    final override = await _client
        .from('disponibilite_capacity_overrides')
        .select('capacite_simultanee')
        .eq('prestataire_id', prestataireId)
        .eq('jour_semaine', pgDow)
        .lte('heure_debut', timeText)
        .gt('heure_fin', timeText)
        .limit(1)
        .maybeSingle();
    final overrideCapacity = (override?['capacite_simultanee'] as num?)
        ?.toInt();
    if (overrideCapacity != null && overrideCapacity > 0) {
      return overrideCapacity;
    }

    final response = await _client
        .from('disponibilites')
        .select('capacite_simultanee')
        .eq('prestataire_id', prestataireId)
        .eq('jour_semaine', pgDow)
        .lte('heure_debut', timeText)
        .gt('heure_fin', timeText)
        .limit(1)
        .maybeSingle();

    return (response?['capacite_simultanee'] as num?)?.toInt() ?? 1;
  }

  Future<int> _activeReservationsCountAtSlot({
    required String prestataireId,
    required DateTime at,
  }) async {
    final start = _startOfMinuteLocal(at);
    final end = start.add(const Duration(minutes: 1));
    final response = await _client
        .from('reservations')
        .select('id, statut')
        .eq('prestataire_id', prestataireId)
        .gte('date_heure', start.toUtc().toIso8601String())
        .lt('date_heure', end.toUtc().toIso8601String());

    var count = 0;
    for (final raw in response as List<dynamic>) {
      final row = Map<String, dynamic>.from(raw as Map);
      final statut = (row['statut'] as String?)?.trim().toLowerCase() ?? '';
      final normalized = statut.replaceAll('é', 'e');
      if (const {'en_attente', 'pending', 'confirmee', 'confirmed'}
          .contains(normalized)) {
        count += 1;
      }
    }
    return count;
  }

  Future<String> _requireClientId() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const BookingNotAuthenticatedFailure();

    final response = await _client
        .from('client_profiles')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) throw const BookingClientProfileMissingFailure();
    return Map<String, dynamic>.from(response)['id'] as String;
  }

  Future<String> _requirePrestataireId() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const BookingNotAuthenticatedFailure();

    final response = await _client
        .from('prestataire_profiles')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) {
      throw AppFailure(DiscBk.errPrestaProfile);
    }
    return Map<String, dynamic>.from(response)['id'] as String;
  }

  List<Reservation> _decodeReservationRows(Object response) {
    return (response as List<dynamic>)
        .map(
          (raw) =>
              SupabaseDomainCodec.reservation(Map<String, dynamic>.from(raw as Map)),
        )
        .toList();
  }

  DateTime _startOfMinuteLocal(DateTime dateHeure) {
    final l = dateHeure.toLocal();
    return DateTime(l.year, l.month, l.day, l.hour, l.minute);
  }

}

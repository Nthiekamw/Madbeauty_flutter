import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/errors/supabase_service_exception.dart';
import '../../../core/logic/booking/booking_create_failure.dart';
import '../../../core/models/domain/booking/client_reservation_summary.dart';
import '../../../core/models/domain/booking/reservation.dart';
import '../../../core/models/domain/serialization/supabase_domain_codec.dart';
import '../profile/profile_service.dart';
import 'booking_mappers.dart';
import 'booking_session_context.dart';
import 'booking_slot_queries.dart';

/// Opérations réservation côté client.
class BookingClientOps {
  BookingClientOps({
    required SupabaseClient client,
    required ProfileService? profileService,
    BookingSessionContext? session,
    BookingSlotQueries? slots,
  })  : _client = client,
        _profileService = profileService,
        _session = session ?? BookingSessionContext(client),
        _slots = slots ?? BookingSlotQueries(client);

  final SupabaseClient _client;
  final ProfileService? _profileService;
  final BookingSessionContext _session;
  final BookingSlotQueries _slots;

  Future<Reservation> create({
    required String prestataireId,
    required String serviceId,
    required DateTime dateHeure,
    String? notesClient,
    String? clientProfileId,
    String? paymentMode,
    int? servicePriceCents,
    int? platformFeeCents,
    int? originalServicePriceCents,
    int? referralDiscountPercent,
  }) {
    return SupabaseErrorHandler.run(
      operation: 'booking.create',
      action: () async {
        final clientId = await _session.requireClientId();
        if (clientProfileId != null &&
            clientProfileId.trim().isNotEmpty &&
            clientProfileId != clientId) {
          throw const BookingForbiddenLookupFailure();
        }

        await _session.rejectIfBookingOwnPrestataire(prestataireId);

        final localSlot = BookingMappers.startOfMinuteLocal(dateHeure);
        final capacity = await _slots.slotCapacityFor(prestataireId, localSlot);
        final bookedCount = await _slots.activeReservationsCountAtSlot(
          prestataireId: prestataireId,
          at: localSlot,
        );
        if (bookedCount >= capacity) {
          throw const BookingSlotTakenFailure();
        }

        var durationMinutes = 30;
        try {
          final serviceRow = await _client
              .from('services_beaute')
              .select('duree_minutes')
              .eq('id', serviceId)
              .maybeSingle();
          final d = (serviceRow?['duree_minutes'] as num?)?.toInt();
          if (d != null && d > 0) durationMinutes = d;
        } catch (_) {}

        final payload = <String, dynamic>{
          'client_id': clientId,
          'prestataire_id': prestataireId,
          'service_id': serviceId,
          'date_heure': localSlot.toUtc().toIso8601String(),
          'statut': 'en_attente',
          'duration_minutes': durationMinutes,
          if (notesClient != null && notesClient.trim().isNotEmpty)
            'notes_client': notesClient.trim(),
          if (paymentMode != null && paymentMode.isNotEmpty)
            'payment_mode': paymentMode,
          if (servicePriceCents != null) 'service_price_cents': servicePriceCents,
          if (platformFeeCents != null) 'platform_fee_cents': platformFeeCents,
          if (paymentMode == 'on_site') 'prestataire_amount_cents': 0,
          if (originalServicePriceCents != null)
            'original_service_price_cents': originalServicePriceCents,
          if (referralDiscountPercent != null && referralDiscountPercent > 0)
            'referral_discount_percent': referralDiscountPercent,
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

  Future<void> cancelClientReservation(String reservationId) {
    return SupabaseErrorHandler.run(
      operation: 'booking.cancelClientReservation',
      action: () async {
        final clientId = await _session.requireClientId();
        await _client
            .from('reservations')
            .update({'statut': 'annulee'})
            .eq('id', reservationId)
            .eq('client_id', clientId);
      },
    );
  }

  Future<List<Reservation>> getByClient(String clientId) {
    return SupabaseErrorHandler.run(
      operation: 'booking.getByClient',
      action: () async {
        final ownId = await _session.requireClientId();
        if (clientId != ownId) {
          throw const BookingForbiddenLookupFailure();
        }

        final response = await _client
            .from('reservations')
            .select()
            .eq('client_id', clientId)
            .order('date_heure', ascending: false);

        return BookingMappers.decodeReservationRows(response);
      },
    );
  }

  Future<ClientReservationSummary?> getClientReservationDetail(
    String reservationId,
  ) {
    return SupabaseErrorHandler.run(
      operation: 'booking.getClientReservationDetail',
      action: () async {
        final clientId = await _session.requireClientId();
        final response = await _client
            .from('reservations')
            .select(
              'id, date_heure, statut, prestataire_id, service_id, '
              'notes_prestataire, amount_cents, currency, '
              'paid_at, payment_status, payment_mode, service_price_cents, '
              'platform_fee_cents, prestataire_amount_cents, notes_client, '
              'services_beaute(nom, duree_minutes), '
              'prestataire_profiles(id, nom_salon, user_id)',
            )
            .eq('id', reservationId)
            .eq('client_id', clientId)
            .maybeSingle();

        if (response == null) return null;

        final map = Map<String, dynamic>.from(response);
        final service = map['services_beaute'];
        final prestataire = map['prestataire_profiles'];
        var summary = BookingMappers.clientReservationSummaryFromRow(
          map,
          service,
          prestataire,
        );

        final userId =
            prestataire is Map ? prestataire['user_id'] as String? : null;
        return BookingMappers.enrichClientDetailWithAvatar(
          summary,
          userId,
          _profileService,
        );
      },
    );
  }

  Future<Reservation?> getById(String id) {
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

  Future<int> countPendingForCurrentClient() {
    return SupabaseErrorHandler.run(
      operation: 'booking.countPendingForCurrentClient',
      action: () async {
        final clientId = await _session.requireClientId();
        final response = await _client
            .from('reservations')
            .select('id')
            .eq('client_id', clientId)
            .eq('statut', 'en_attente');
        return (response as List<dynamic>).length;
      },
    );
  }

  Future<List<ClientReservationSummary>> listForCurrentClient() {
    return SupabaseErrorHandler.run(
      operation: 'booking.listForCurrentClient',
      action: () async {
        final clientId = await _session.requireClientId();
        final response = await _client
            .from('reservations')
            .select(
              'id, date_heure, statut, prestataire_id, service_id, '
              'notes_prestataire, amount_cents, currency, '
              'paid_at, payment_status, payment_mode, service_price_cents, '
              'platform_fee_cents, prestataire_amount_cents, '
              'services_beaute(nom, duree_minutes), '
              'prestataire_profiles(id, nom_salon, user_id)',
            )
            .eq('client_id', clientId)
            .order('date_heure', ascending: false);

        final rawRows = response as List<dynamic>;
        final summaries = <ClientReservationSummary>[];

        for (final raw in rawRows) {
          final map = Map<String, dynamic>.from(raw as Map);
          summaries.add(
            BookingMappers.clientReservationSummaryFromRow(
              map,
              map['services_beaute'],
              map['prestataire_profiles'],
            ),
          );
        }

        return BookingMappers.enrichClientSummariesWithAvatars(
          rawRows,
          summaries,
          _profileService,
        );
      },
    );
  }
}

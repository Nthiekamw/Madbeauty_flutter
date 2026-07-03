import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/logic/booking/booking_create_failure.dart';
import '../../../core/models/domain/booking/prestataire_reservation_item.dart';
import '../../../core/models/domain/booking/reservation.dart';
import '../../../core/models/domain/prestataire/prestataire_analytics_reservation.dart';
import '../profile/profile_service.dart';
import 'booking_mappers.dart';
import 'booking_session_context.dart';

/// Opérations réservation côté prestataire.
class BookingPrestataireOps {
  BookingPrestataireOps({
    required SupabaseClient client,
    required ProfileService? profileService,
    BookingSessionContext? session,
  })  : _client = client,
        _profileService = profileService,
        _session = session ?? BookingSessionContext(client);

  final SupabaseClient _client;
  final ProfileService? _profileService;
  final BookingSessionContext _session;

  Future<void> rejectByPrestataire(
    String bookingId, {
    String? reason,
  }) {
    return SupabaseErrorHandler.run(
      operation: 'booking.rejectByPrestataire',
      action: () async {
        await _session.requirePrestataireId();

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
        final s = BookingMappers.normalizeStatut(snapshot['statut']);
        if (const {'annulee', 'cancelled', 'canceled'}.contains(s)) return;

        throw AppFailure(DiscBk.errResBadState);
      },
    );
  }

  Future<void> confirm(String bookingId) {
    return SupabaseErrorHandler.run(
      operation: 'booking.confirm',
      action: () async {
        await _session.requirePrestataireId();

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
        final s = BookingMappers.normalizeStatut(snapshot['statut']);
        if (const {'confirmee', 'confirmed'}.contains(s)) return;

        throw AppFailure(DiscBk.errResBadState);
      },
    );
  }

  Future<void> markAsDone(String bookingId) {
    return SupabaseErrorHandler.run(
      operation: 'booking.markAsDone',
      action: () async {
        await _session.requirePrestataireId();

        final snapshot = await _client
            .from('reservations')
            .select('statut, date_heure, services_beaute(duree_minutes)')
            .eq('id', bookingId)
            .maybeSingle();

        if (snapshot == null) {
          throw AppFailure(DiscBk.errResMissing);
        }

        final s = BookingMappers.normalizeStatut(snapshot['statut']);
        if (const {'terminee', 'done', 'completed'}.contains(s)) {
          return;
        }
        if (s != 'confirmee' && s != 'confirmed') {
          throw AppFailure(DiscBk.errResBadState);
        }

        final start =
            DateTime.parse(snapshot['date_heure'] as String).toLocal();
        final service = snapshot['services_beaute'];
        final duration = service is Map
            ? (service['duree_minutes'] as num?)?.toInt() ?? 60
            : 60;
        final end = start.add(Duration(minutes: duration <= 0 ? 60 : duration));
        if (end.isAfter(DateTime.now())) {
          throw AppFailure(DiscBk.errMarkDoneTooEarly);
        }

        final updated = await _client
            .from('reservations')
            .update({'statut': 'terminee'})
            .eq('id', bookingId)
            .eq('statut', 'confirmee')
            .select('id');

        final got = updated as List<dynamic>;
        if (got.isNotEmpty) {
          return;
        }

        final retry = await _client
            .from('reservations')
            .select('statut')
            .eq('id', bookingId)
            .maybeSingle();
        if (retry == null) {
          throw AppFailure(DiscBk.errResMissing);
        }
        final retryS = BookingMappers.normalizeStatut(retry['statut']);
        if (const {'terminee', 'done', 'completed'}.contains(retryS)) {
          return;
        }

        throw AppFailure(DiscBk.errResBadState);
      },
    );
  }

  Future<List<Reservation>> getByPrestataire(String prestataireId) {
    return SupabaseErrorHandler.run(
      operation: 'booking.getByPrestataire',
      action: () async {
        final ownId = await _session.requirePrestataireId();
        if (prestataireId != ownId) {
          throw const BookingForbiddenLookupFailure();
        }

        final response = await _client
            .from('reservations')
            .select()
            .eq('prestataire_id', prestataireId)
            .order('date_heure', ascending: false);

        return BookingMappers.decodeReservationRows(response);
      },
    );
  }

  Future<List<PrestataireAnalyticsReservation>>
      listAnalyticsForCurrentPrestataire({
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) {
    return SupabaseErrorHandler.run(
      operation: 'booking.listAnalyticsForCurrentPrestataire',
      action: () async {
        final prestataireId = await _session.requirePrestataireId();
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

        return (response as List<dynamic>)
            .map(
              (raw) => BookingMappers.analyticsReservationFromRow(
                Map<String, dynamic>.from(raw as Map),
              ),
            )
            .toList();
      },
    );
  }

  Future<List<PrestataireReservationItem>> listForCurrentPrestataire() {
    return SupabaseErrorHandler.run(
      operation: 'booking.listForCurrentPrestataire',
      action: () async {
        final prestataireId = await _session.requirePrestataireId();
        final response = await _client
            .from('reservations')
            .select(
              'id, date_heure, statut, client_id, notes_client, notes_prestataire, '
              'amount_cents, payment_status, payment_mode, service_price_cents, '
              'platform_fee_cents, prestataire_amount_cents, '
              'services_beaute(nom, duree_minutes), client_profiles(user_id)',
            )
            .eq('prestataire_id', prestataireId)
            .order('date_heure', ascending: true);

        final rows = response as List<dynamic>;
        if (rows.isEmpty) return const [];

        final items = <PrestataireReservationItem>[];
        for (final raw in rows) {
          final map = Map<String, dynamic>.from(raw as Map);
          items.add(
            BookingMappers.prestataireReservationItemFromRow(
              map,
              map['services_beaute'],
              '',
            ),
          );
        }

        return BookingMappers.enrichPrestataireItemsWithProfiles(
          rows,
          items,
          _profileService,
        );
      },
    );
  }

}

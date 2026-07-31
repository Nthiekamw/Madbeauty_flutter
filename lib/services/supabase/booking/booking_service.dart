import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/domain/booking/client_reservation_summary.dart';
import '../../../core/models/domain/booking/prestataire_reservation_item.dart';
import '../../../core/models/domain/booking/reservation.dart';
import '../../../core/models/domain/prestataire/prestataire_analytics_reservation.dart';
import '../profile/profile_service.dart';
import 'booking_client_ops.dart';
import 'booking_prestataire_ops.dart';
import 'booking_session_context.dart';
import 'booking_slot_queries.dart';

/// Façade réservations — délègue aux ops client / prestataire.
class BookingService {
  BookingService(SupabaseClient client, ProfileService? profileService)
      : _clientOps = BookingClientOps(
          client: client,
          profileService: profileService,
          session: BookingSessionContext(client),
          slots: BookingSlotQueries(client),
        ),
        _prestataireOps = BookingPrestataireOps(
          client: client,
          profileService: profileService,
          session: BookingSessionContext(client),
        );

  final BookingClientOps _clientOps;
  final BookingPrestataireOps _prestataireOps;

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
    int? vipDiscountPercent,
    int? loyaltyRewardCents,
  }) =>
      _clientOps.create(
        prestataireId: prestataireId,
        serviceId: serviceId,
        dateHeure: dateHeure,
        notesClient: notesClient,
        clientProfileId: clientProfileId,
        paymentMode: paymentMode,
        servicePriceCents: servicePriceCents,
        platformFeeCents: platformFeeCents,
        originalServicePriceCents: originalServicePriceCents,
        referralDiscountPercent: referralDiscountPercent,
        vipDiscountPercent: vipDiscountPercent,
        loyaltyRewardCents: loyaltyRewardCents,
      );

  Future<void> cancel(String bookingId) =>
      cancelClientReservation(bookingId);

  Future<void> rejectByPrestataire(String bookingId, {String? reason}) =>
      _prestataireOps.rejectByPrestataire(bookingId, reason: reason);

  Future<void> cancelClientReservation(String reservationId) =>
      _clientOps.cancelClientReservation(reservationId);

  Future<void> confirm(String bookingId) =>
      _prestataireOps.confirm(bookingId);

  Future<void> markAsDone(String bookingId) =>
      _prestataireOps.markAsDone(bookingId);

  Future<List<Reservation>> getByClient(String clientId) =>
      _clientOps.getByClient(clientId);

  Future<List<Reservation>> getByPrestataire(String prestataireId) =>
      _prestataireOps.getByPrestataire(prestataireId);

  Future<ClientReservationSummary?> getClientReservationDetail(
    String reservationId,
  ) =>
      _clientOps.getClientReservationDetail(reservationId);

  Future<Reservation?> getById(String id) => _clientOps.getById(id);

  Future<List<PrestataireAnalyticsReservation>>
      listAnalyticsForCurrentPrestataire({
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) =>
          _prestataireOps.listAnalyticsForCurrentPrestataire(
            rangeStart: rangeStart,
            rangeEnd: rangeEnd,
          );

  Future<List<PrestataireReservationItem>> listForCurrentPrestataire() =>
      _prestataireOps.listForCurrentPrestataire();

  Future<int> countPendingForCurrentClient() =>
      _clientOps.countPendingForCurrentClient();

  Future<List<ClientReservationSummary>> listForCurrentClient() =>
      _clientOps.listForCurrentClient();
}

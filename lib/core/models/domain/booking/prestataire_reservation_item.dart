import 'package:madbeauty/core/logic/booking/reservation_payment_display.dart';

/// Réservation enrichie pour le tableau de bord / agenda prestataire.
class PrestataireReservationItem {
  const PrestataireReservationItem({
    required this.id,
    required this.dateHeure,
    required this.statut,
    required this.serviceName,
    required this.clientName,
    this.clientId,
    this.clientAvatarUrl,
    this.notesClient,
    this.notesPrestataire,
    this.amountCents,
    this.paymentStatus,
    this.paymentMode,
    this.servicePriceCents,
    this.platformFeeCents,
    this.prestataireAmountCents,
    this.durationMinutes = 60,
  });

  final String id;
  final DateTime dateHeure;
  final String statut;
  final String serviceName;
  final String clientName;
  final String? clientId;
  final String? clientAvatarUrl;
  final String? notesClient;
  final String? notesPrestataire;
  final int? amountCents;
  final String? paymentStatus;
  final String? paymentMode;
  final int? servicePriceCents;
  final int? platformFeeCents;
  final int? prestataireAmountCents;
  final int durationMinutes;

  ReservationPaymentDisplay get paymentDisplay =>
      ReservationPaymentDisplay.fromFields(
        paymentMode: paymentMode,
        servicePriceCents: servicePriceCents,
        platformFeeCents: platformFeeCents,
        prestataireAmountCents: prestataireAmountCents,
        amountCents: amountCents,
        paymentStatus: paymentStatus,
      );
}

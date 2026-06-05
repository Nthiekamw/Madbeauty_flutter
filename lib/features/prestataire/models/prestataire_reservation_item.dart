import '../../booking/logic/reservation_payment_display.dart';

/// Réservation enrichie pour le tableau de bord prestataire.
class PrestataireReservationItem {
  const PrestataireReservationItem({
    required this.id,
    required this.dateHeure,
    required this.statut,
    required this.serviceName,
    required this.clientName,
    this.clientId,
    this.notesClient,
    this.notesPrestataire,
    this.amountCents,
    this.paymentStatus,
    this.paymentMode,
    this.servicePriceCents,
    this.platformFeeCents,
    this.prestataireAmountCents,
  });

  final String id;
  final DateTime dateHeure;
  final String statut;
  final String serviceName;
  final String clientName;
  final String? clientId;
  final String? notesClient;
  final String? notesPrestataire;
  final int? amountCents;
  final String? paymentStatus;
  final String? paymentMode;
  final int? servicePriceCents;
  final int? platformFeeCents;
  final int? prestataireAmountCents;

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

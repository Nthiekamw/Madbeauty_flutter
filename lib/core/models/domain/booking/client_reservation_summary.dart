import 'package:madbeauty/core/logic/booking/reservation_payment_display.dart';

/// Résumé réservation côté client (listes, détail, cache offline).
class ClientReservationSummary {
  const ClientReservationSummary({
    required this.id,
    required this.dateHeure,
    required this.statut,
    this.serviceName,
    this.prestataireId,
    this.prestataireName,
    this.prestataireAvatarUrl,
    this.amountCents,
    this.currency,
    this.paidAt,
    this.paymentStatus,
    this.paymentMode,
    this.servicePriceCents,
    this.platformFeeCents,
    this.prestataireAmountCents,
    this.serviceId,
    this.notesPrestataire,
    this.durationMinutes = 60,
  });

  final String id;
  final DateTime dateHeure;
  final String statut;
  final String? serviceName;
  final String? prestataireId;
  final String? prestataireName;
  final String? prestataireAvatarUrl;
  final int? amountCents;
  final String? currency;
  final DateTime? paidAt;
  final String? paymentStatus;
  final String? paymentMode;
  final int? servicePriceCents;
  final int? platformFeeCents;
  final int? prestataireAmountCents;
  final String? serviceId;
  final String? notesPrestataire;
  final int durationMinutes;

  bool get hasRejectReason =>
      notesPrestataire != null && notesPrestataire!.trim().isNotEmpty;

  ReservationPaymentDisplay get paymentDisplay =>
      ReservationPaymentDisplay.fromFields(
        paymentMode: paymentMode,
        servicePriceCents: servicePriceCents,
        platformFeeCents: platformFeeCents,
        prestataireAmountCents: prestataireAmountCents,
        amountCents: amountCents,
        paymentStatus: paymentStatus,
      );

  bool get hasPaymentReceipt =>
      amountCents != null &&
      amountCents! > 0 &&
      paidAt != null &&
      (paymentStatus == 'authorized' || paymentStatus == 'captured');

  String get formattedPaidAmount {
    if (amountCents == null) return '';
    return formatCentsEur(amountCents!);
  }
}

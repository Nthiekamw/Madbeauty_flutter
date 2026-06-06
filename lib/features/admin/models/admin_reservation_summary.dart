class AdminReservationSummary {
  const AdminReservationSummary({
    required this.id,
    required this.dateHeure,
    required this.statut,
    this.paymentStatus,
    this.paymentMode,
    this.amountCents,
    this.currency,
    this.clientName,
    this.prestataireSalon,
    this.serviceName,
    this.stripePaymentIntentId,
    this.paidAt,
  });

  final String id;
  final DateTime dateHeure;
  final String statut;
  final String? paymentStatus;
  final String? paymentMode;
  final int? amountCents;
  final String? currency;
  final String? clientName;
  final String? prestataireSalon;
  final String? serviceName;
  final String? stripePaymentIntentId;
  final DateTime? paidAt;
}

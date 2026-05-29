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
  });

  final String id;
  final DateTime dateHeure;
  final String statut;
  final String? serviceName;
  final String? prestataireId;
  final String? prestataireName;
  /// Photo affichée dans la liste (profil identité du prestataire).
  final String? prestataireAvatarUrl;
  final int? amountCents;
  final String? currency;
  final DateTime? paidAt;
  final String? paymentStatus;

  bool get hasPaymentReceipt =>
      amountCents != null &&
      amountCents! > 0 &&
      paidAt != null &&
      (paymentStatus == 'authorized' || paymentStatus == 'captured');

  String get formattedPaidAmount {
    if (amountCents == null) return '';
    final euros = amountCents! / 100;
    return '${euros.toStringAsFixed(2)} €';
  }
}

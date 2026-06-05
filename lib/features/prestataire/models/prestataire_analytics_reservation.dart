/// Ligne réservation pour les calculs analytiques prestataire.
class PrestataireAnalyticsReservation {
  const PrestataireAnalyticsReservation({
    required this.dateHeure,
    required this.statut,
    this.amountCents,
    this.paymentStatus,
    required this.servicePriceEur,
  });

  final DateTime dateHeure;
  final String statut;
  final int? amountCents;
  final String? paymentStatus;
  final double servicePriceEur;
}


class AdminBoutiqueOrderSummary {
  const AdminBoutiqueOrderSummary({
    required this.id,
    required this.createdAt,
    required this.statut,
    required this.paymentStatus,
    required this.amountCents,
    required this.prestataireId,
    this.currency = 'eur',
    this.fulfillment,
    this.clientName,
    this.prestataireSalon,
    this.itemsCount = 0,
    this.stripePaymentIntentId,
    this.paidAt,
  });

  final String id;
  final DateTime createdAt;
  final String statut;
  final String paymentStatus;
  final int amountCents;
  final String currency;
  final String? fulfillment;
  final String? clientName;
  final String? prestataireSalon;
  final String prestataireId;
  final int itemsCount;
  final String? stripePaymentIntentId;
  final DateTime? paidAt;

  double get amountEuros => amountCents / 100;
}

class AdminBoutiqueCatalogRow {
  const AdminBoutiqueCatalogRow({
    required this.prestataireId,
    required this.prestataireSalon,
    this.ville,
    this.produitsActifs = 0,
    this.produitsTotal = 0,
    this.packsActifs = 0,
    this.packsTotal = 0,
    this.commandesOuvertes = 0,
    this.commandesTotal = 0,
  });

  final String prestataireId;
  final String prestataireSalon;
  final String? ville;
  final int produitsActifs;
  final int produitsTotal;
  final int packsActifs;
  final int packsTotal;
  final int commandesOuvertes;
  final int commandesTotal;
}

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
    this.packId,
    this.reservationId,
    this.notesClient,
    this.hasAvis = false,
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
  final String? packId;
  final String? reservationId;
  final String? notesClient;
  final bool hasAvis;

  double get amountEuros => amountCents / 100;

  bool get isPackLinked {
    final pack = packId?.trim();
    final reservation = reservationId?.trim();
    return (pack != null && pack.isNotEmpty) ||
        (reservation != null && reservation.isNotEmpty);
  }
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

class AdminBoutiqueAvisSummary {
  const AdminBoutiqueAvisSummary({
    required this.id,
    required this.createdAt,
    required this.note,
    required this.commandeId,
    required this.prestataireId,
    this.commentaire,
    this.clientName,
    this.prestataireSalon,
    this.commandeStatut,
  });

  final String id;
  final DateTime createdAt;
  final int note;
  final String? commentaire;
  final String commandeId;
  final String? clientName;
  final String? prestataireSalon;
  final String prestataireId;
  final String? commandeStatut;
}

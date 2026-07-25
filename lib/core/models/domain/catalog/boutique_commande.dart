/// Statuts métier d’une commande boutique.
enum BoutiqueCommandeStatut {
  pendingPayment,
  payOnSite,
  paid,
  preparing,
  ready,
  completed,
  canceled;

  static BoutiqueCommandeStatut fromDb(String? raw) {
    return switch (raw?.trim()) {
      'pending_payment' => pendingPayment,
      'pay_on_site' => payOnSite,
      'paid' => paid,
      'preparing' => preparing,
      'ready' => ready,
      'completed' => completed,
      'canceled' => canceled,
      _ => pendingPayment,
    };
  }

  String get dbValue => switch (this) {
        pendingPayment => 'pending_payment',
        payOnSite => 'pay_on_site',
        paid => 'paid',
        preparing => 'preparing',
        ready => 'ready',
        completed => 'completed',
        canceled => 'canceled',
      };

  bool get isOpen =>
      this == pendingPayment ||
      this == payOnSite ||
      this == paid ||
      this == preparing ||
      this == ready;

  /// Prochaine étape métier pour le prestataire (null si terminal).
  BoutiqueCommandeStatut? get nextForPrestataire => switch (this) {
        payOnSite || paid => preparing,
        preparing => ready,
        ready => completed,
        _ => null,
      };
}

class BoutiqueCommandeItem {
  const BoutiqueCommandeItem({
    required this.id,
    required this.commandeId,
    required this.nomSnapshot,
    required this.prixCents,
    required this.quantite,
    this.produitId,
    this.conditionnementSnapshot,
  });

  final String id;
  final String commandeId;
  final String? produitId;
  final String nomSnapshot;
  final String? conditionnementSnapshot;
  final int prixCents;
  final int quantite;

  double get lineTotalEuros => (prixCents * quantite) / 100;

  factory BoutiqueCommandeItem.fromJson(Map<String, dynamic> json) {
    return BoutiqueCommandeItem(
      id: json['id'] as String,
      commandeId: json['commande_id'] as String,
      produitId: json['produit_id'] as String?,
      nomSnapshot: json['nom_snapshot'] as String? ?? '',
      conditionnementSnapshot: json['conditionnement_snapshot'] as String?,
      prixCents: (json['prix_cents'] as num?)?.toInt() ?? 0,
      quantite: (json['quantite'] as num?)?.toInt() ?? 1,
    );
  }
}

class BoutiqueCommande {
  const BoutiqueCommande({
    required this.id,
    required this.clientId,
    required this.prestataireId,
    required this.statut,
    required this.paymentStatus,
    required this.amountCents,
    required this.createdAt,
    this.currency = 'eur',
    this.fulfillment = 'pickup',
    this.notesClient,
    this.paidAt,
    this.items = const [],
    this.clientDisplayName,
    this.prestataireDisplayName,
  });

  final String id;
  final String clientId;
  final String prestataireId;
  final BoutiqueCommandeStatut statut;
  final String paymentStatus;
  final int amountCents;
  final String currency;
  final String fulfillment;
  final String? notesClient;
  final DateTime createdAt;
  final DateTime? paidAt;
  final List<BoutiqueCommandeItem> items;
  final String? clientDisplayName;
  final String? prestataireDisplayName;

  double get amountEuros => amountCents / 100;

  BoutiqueCommande copyWith({
    String? clientDisplayName,
    String? prestataireDisplayName,
  }) {
    return BoutiqueCommande(
      id: id,
      clientId: clientId,
      prestataireId: prestataireId,
      statut: statut,
      paymentStatus: paymentStatus,
      amountCents: amountCents,
      currency: currency,
      fulfillment: fulfillment,
      notesClient: notesClient,
      createdAt: createdAt,
      paidAt: paidAt,
      items: items,
      clientDisplayName: clientDisplayName ?? this.clientDisplayName,
      prestataireDisplayName:
          prestataireDisplayName ?? this.prestataireDisplayName,
    );
  }

  factory BoutiqueCommande.fromJson(Map<String, dynamic> json) {
    final rawItems = json['boutique_commande_items'];
    final items = <BoutiqueCommandeItem>[];
    if (rawItems is List) {
      for (final row in rawItems) {
        if (row is Map) {
          items.add(
            BoutiqueCommandeItem.fromJson(Map<String, dynamic>.from(row)),
          );
        }
      }
    }

    String? salonName;
    final prestaRaw = json['prestataire_profiles'];
    if (prestaRaw is Map) {
      final nomAffiche = (prestaRaw['nom_affiche'] as String?)?.trim() ?? '';
      final nomSalon = (prestaRaw['nom_salon'] as String?)?.trim() ?? '';
      salonName = nomAffiche.isNotEmpty
          ? nomAffiche
          : (nomSalon.isNotEmpty ? nomSalon : null);
    }

    return BoutiqueCommande(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      prestataireId: json['prestataire_id'] as String,
      statut: BoutiqueCommandeStatut.fromDb(json['statut'] as String?),
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      amountCents: (json['amount_cents'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'eur',
      fulfillment: json['fulfillment'] as String? ?? 'pickup',
      notesClient: json['notes_client'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      paidAt: json['paid_at'] == null
          ? null
          : DateTime.tryParse(json['paid_at'] as String),
      items: List.unmodifiable(items),
      clientDisplayName: null,
      prestataireDisplayName: salonName,
    );
  }

  /// Extrait `user_id` du join `client_profiles` (si présent).
  static String? clientUserIdFromJson(Map<String, dynamic> json) {
    final clientRaw = json['client_profiles'];
    if (clientRaw is Map) {
      return clientRaw['user_id'] as String?;
    }
    return null;
  }
}

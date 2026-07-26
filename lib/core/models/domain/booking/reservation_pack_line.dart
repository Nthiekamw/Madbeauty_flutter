/// Ligne snapshot d’un pack réservé (`reservation_pack_items`).
class ReservationPackLine {
  const ReservationPackLine({
    required this.itemType,
    required this.label,
    required this.quantite,
    this.sortOrder = 0,
  });

  /// `service` | `produit`
  final String itemType;
  final String label;
  final int quantite;
  final int sortOrder;

  bool get isService => itemType == 'service';
  bool get isProduit => itemType == 'produit';

  factory ReservationPackLine.fromJson(Map<String, dynamic> json) {
    return ReservationPackLine(
      itemType: (json['item_type'] as String?)?.trim() ?? 'service',
      label: (json['label'] as String?)?.trim() ?? '',
      quantite: (json['quantite'] as num?)?.toInt() ?? 1,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'item_type': itemType,
        'label': label,
        'quantite': quantite,
        'sort_order': sortOrder,
      };
}

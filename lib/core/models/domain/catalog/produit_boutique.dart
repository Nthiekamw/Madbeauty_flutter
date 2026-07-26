import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';

part 'produit_boutique.freezed.dart';
part 'produit_boutique.g.dart';

/// Catégories produit boutique (alignées sur le check SQL).
enum ProduitBoutiqueCategorie {
  @JsonValue('cheveux')
  cheveux,
  @JsonValue('visage')
  visage,
  @JsonValue('corps')
  corps,
  @JsonValue('accessoires')
  accessoires,
  @JsonValue('autre')
  autre;

  static ProduitBoutiqueCategorie fromDb(String? raw) {
    final v = raw?.trim().toLowerCase();
    return switch (v) {
      'cheveux' => cheveux,
      'visage' => visage,
      'corps' => corps,
      'accessoires' => accessoires,
      _ => autre,
    };
  }

  String get dbValue => switch (this) {
        cheveux => 'cheveux',
        visage => 'visage',
        corps => 'corps',
        accessoires => 'accessoires',
        autre => 'autre',
      };
}

/// [PRODUITS_BOUTIQUE]
@freezed
abstract class ProduitBoutique with _$ProduitBoutique {
  const factory ProduitBoutique({
    required String id,
    required String prestataireId,
    required String nom,
    String? description,
    String? conditionnement,
    @Default(ProduitBoutiqueCategorie.autre) ProduitBoutiqueCategorie categorie,
    @DecimalConverter() @Default(0) double prix,
    String? imageUrl,
    @Default(true) bool isActif,
    @Default(false) bool stockIllimite,
    @Default(0) int stockQty,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProduitBoutique;

  factory ProduitBoutique.fromJson(Map<String, dynamic> json) =>
      _$ProduitBoutiqueFromJson(json);
}

/// Helpers stock (hors Freezed pour tests unitaires).
extension ProduitBoutiqueStock on ProduitBoutique {
  /// Null = illimité.
  int? get maxOrderableQty =>
      stockIllimite ? null : (stockQty < 0 ? 0 : stockQty);

  bool get isInStock => stockIllimite || stockQty > 0;

  bool get isLowStock =>
      !stockIllimite && stockQty > 0 && stockQty <= 3;

  bool get isOutOfStock => !stockIllimite && stockQty <= 0;

  /// Plafonne [wanted] au stock disponible (ignore si illimité).
  int clampOrderQty(int wanted) {
    final q = wanted < 1 ? 1 : wanted;
    final max = maxOrderableQty;
    if (max == null) return q;
    if (max <= 0) return 0;
    return q > max ? max : q;
  }
}

/// Plafonne une quantité panier par rapport au max stock (null = illimité).
int clampCartQuantity(int wanted, int? maxOrderable) {
  final q = wanted < 1 ? 0 : wanted;
  if (maxOrderable == null) return q < 1 ? 1 : q;
  if (maxOrderable <= 0) return 0;
  if (q < 1) return 0;
  return q > maxOrderable ? maxOrderable : q;
}

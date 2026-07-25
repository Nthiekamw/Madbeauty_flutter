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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProduitBoutique;

  factory ProduitBoutique.fromJson(Map<String, dynamic> json) =>
      _$ProduitBoutiqueFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';

part 'pack_offre.freezed.dart';
part 'pack_offre.g.dart';

/// [PACKS_OFFRE]
@freezed
abstract class PackOffre with _$PackOffre {
  const factory PackOffre({
    required String id,
    required String prestataireId,
    required String titre,
    String? description,
    String? imageUrl,
    @DecimalConverter() required double prixPack,
    @Default(false) bool isOffreDuJour,
    @Default(false) bool isActif,
    DateTime? startsAt,
    DateTime? endsAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PackOffre;

  factory PackOffre.fromJson(Map<String, dynamic> json) =>
      _$PackOffreFromJson(json);
}

extension PackOffrePricing on PackOffre {
  /// Remise affichée vs [prixCatalogue], null si pas de baisse.
  double? discountPercent(double prixCatalogue) {
    if (prixCatalogue <= 0 || prixPack >= prixCatalogue) return null;
    return ((prixCatalogue - prixPack) / prixCatalogue) * 100;
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'prestataire_specialite.freezed.dart';
part 'prestataire_specialite.g.dart';

/// [PRESTATAIRE_SPECIALITES] — clé composite (prestataire_id, categorie_id).
@freezed
abstract class PrestataireSpecialite with _$PrestataireSpecialite {
  const factory PrestataireSpecialite({
    required String prestataireId,
    required String categorieId,
  }) = _PrestataireSpecialite;

  factory PrestataireSpecialite.fromJson(Map<String, dynamic> json) =>
      _$PrestataireSpecialiteFromJson(json);
}

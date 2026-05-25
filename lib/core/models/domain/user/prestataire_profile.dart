import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';
import 'lieu_travail.dart';
import 'lieu_travail_converter.dart';

part 'prestataire_profile.freezed.dart';
part 'prestataire_profile.g.dart';

List<String> _conditionsServiceFromJson(dynamic raw) {
  if (raw == null) return [];
  if (raw is List) {
    return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }
  if (raw is String && raw.trim().isNotEmpty) {
    return [raw.trim()];
  }
  return [];
}

/// [PRESTATAIRE_PROFILES]
@freezed
abstract class PrestataireProfile with _$PrestataireProfile {
  const factory PrestataireProfile({
    required String id,
    required String userId,
    String? nomSalon,
    String? bio,
    String? ville,
    String? adresse,
    @JsonKey(name: 'code_postal') String? codePostal,
    @JsonKey(name: 'nom_affiche') String? nomAffiche,
    @JsonKey(name: 'lieu_travail')
    @LieuTravailConverter()
    LieuTravail? lieuTravail,
    @JsonKey(name: 'annees_experience') String? anneesExperience,
    @JsonKey(name: 'experience_professionnelle') String? experienceProfessionnelle,
    String? description,
    @JsonKey(name: 'confort_client') @Default([]) List<String> confortClient,
    @JsonKey(name: 'conditions_service', fromJson: _conditionsServiceFromJson)
    @Default([])
    List<String> conditionsService,
    double? latitude,
    double? longitude,
    double? noteMoyenne,
    @Default(false) bool isVerified,
    @IsoDateTimeConverter() required DateTime createdAt,
  }) = _PrestataireProfile;

  factory PrestataireProfile.fromJson(Map<String, dynamic> json) =>
      _$PrestataireProfileFromJson(json);
}

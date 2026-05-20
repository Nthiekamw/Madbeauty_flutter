import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';
import 'lieu_travail.dart';
import 'lieu_travail_converter.dart';

part 'prestataire_profile.freezed.dart';
part 'prestataire_profile.g.dart';

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
    double? latitude,
    double? longitude,
    double? noteMoyenne,
    @Default(false) bool isVerified,
    @IsoDateTimeConverter() required DateTime createdAt,
  }) = _PrestataireProfile;

  factory PrestataireProfile.fromJson(Map<String, dynamic> json) =>
      _$PrestataireProfileFromJson(json);
}

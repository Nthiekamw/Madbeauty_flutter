import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';

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
    double? latitude,
    double? longitude,
    double? noteMoyenne,
    @Default(false) bool isVerified,
    @IsoDateTimeConverter() required DateTime createdAt,
  }) = _PrestataireProfile;

  factory PrestataireProfile.fromJson(Map<String, dynamic> json) =>
      _$PrestataireProfileFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';

part 'client_profile.freezed.dart';
part 'client_profile.g.dart';

/// [CLIENT_PROFILES]
@freezed
abstract class ClientProfile with _$ClientProfile {
  const factory ClientProfile({
    required String id,
    required String userId,
    String? adresse,
    String? ville,
    @JsonKey(name: 'code_postal') String? codePostal,
    String? pays,
    @JsonKey(name: 'voie_type') String? voieType,
    @JsonKey(name: 'voie_nom') String? voieNom,
    @JsonKey(name: 'numero_rue') String? numeroRue,
    double? latitude,
    double? longitude,
    @IsoDateTimeConverter() required DateTime createdAt,
  }) = _ClientProfile;

  factory ClientProfile.fromJson(Map<String, dynamic> json) =>
      _$ClientProfileFromJson(json);
}


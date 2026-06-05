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
    @IsoDateTimeConverter() required DateTime createdAt,
  }) = _ClientProfile;

  factory ClientProfile.fromJson(Map<String, dynamic> json) =>
      _$ClientProfileFromJson(json);
}


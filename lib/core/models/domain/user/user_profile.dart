import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// [USER_PROFILES]
@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String userId,
    String? nom,
    String? prenom,
    String? avatarUrl,
    String? telephone,
    @IsoDateTimeConverter() required DateTime updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}


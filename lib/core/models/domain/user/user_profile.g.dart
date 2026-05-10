// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  nom: json['nom'] as String?,
  prenom: json['prenom'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  telephone: json['telephone'] as String?,
  updatedAt: const IsoDateTimeConverter().fromJson(json['updated_at']),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'nom': instance.nom,
      'prenom': instance.prenom,
      'avatar_url': instance.avatarUrl,
      'telephone': instance.telephone,
      'updated_at': const IsoDateTimeConverter().toJson(instance.updatedAt),
    };

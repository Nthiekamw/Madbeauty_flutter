// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  id: json['id'] as String,
  email: json['email'] as String,
  passwordHash: json['password_hash'] as String?,
  createdAt: const IsoDateTimeConverter().fromJson(json['created_at']),
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'password_hash': instance.passwordHash,
  'created_at': const IsoDateTimeConverter().toJson(instance.createdAt),
};

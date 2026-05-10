// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientProfile _$ClientProfileFromJson(Map<String, dynamic> json) =>
    _ClientProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      adresse: json['adresse'] as String?,
      createdAt: const IsoDateTimeConverter().fromJson(json['created_at']),
    );

Map<String, dynamic> _$ClientProfileToJson(_ClientProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'adresse': instance.adresse,
      'created_at': const IsoDateTimeConverter().toJson(instance.createdAt),
    };

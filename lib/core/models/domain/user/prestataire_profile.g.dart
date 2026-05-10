// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prestataire_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrestataireProfile _$PrestataireProfileFromJson(Map<String, dynamic> json) =>
    _PrestataireProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      nomSalon: json['nom_salon'] as String?,
      bio: json['bio'] as String?,
      ville: json['ville'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      noteMoyenne: (json['note_moyenne'] as num?)?.toDouble(),
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: const IsoDateTimeConverter().fromJson(json['created_at']),
    );

Map<String, dynamic> _$PrestataireProfileToJson(_PrestataireProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'nom_salon': instance.nomSalon,
      'bio': instance.bio,
      'ville': instance.ville,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'note_moyenne': instance.noteMoyenne,
      'is_verified': instance.isVerified,
      'created_at': const IsoDateTimeConverter().toJson(instance.createdAt),
    };

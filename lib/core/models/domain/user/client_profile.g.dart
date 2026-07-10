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
      ville: json['ville'] as String?,
      codePostal: json['code_postal'] as String?,
      pays: json['pays'] as String?,
      voieType: json['voie_type'] as String?,
      voieNom: json['voie_nom'] as String?,
      numeroRue: json['numero_rue'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: const IsoDateTimeConverter().fromJson(json['created_at']),
    );

Map<String, dynamic> _$ClientProfileToJson(_ClientProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'adresse': instance.adresse,
      'ville': instance.ville,
      'code_postal': instance.codePostal,
      'pays': instance.pays,
      'voie_type': instance.voieType,
      'voie_nom': instance.voieNom,
      'numero_rue': instance.numeroRue,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'created_at': const IsoDateTimeConverter().toJson(instance.createdAt),
    };

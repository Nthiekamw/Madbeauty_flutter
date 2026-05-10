// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_beaute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ServiceBeaute _$ServiceBeauteFromJson(Map<String, dynamic> json) =>
    _ServiceBeaute(
      id: json['id'] as String,
      prestataireId: json['prestataire_id'] as String,
      nom: json['nom'] as String,
      dureeMinutes: (json['duree_minutes'] as num).toInt(),
      prix: const DecimalConverter().fromJson(json['prix']),
      isActif: json['is_actif'] as bool? ?? true,
    );

Map<String, dynamic> _$ServiceBeauteToJson(_ServiceBeaute instance) =>
    <String, dynamic>{
      'id': instance.id,
      'prestataire_id': instance.prestataireId,
      'nom': instance.nom,
      'duree_minutes': instance.dureeMinutes,
      'prix': const DecimalConverter().toJson(instance.prix),
      'is_actif': instance.isActif,
    };

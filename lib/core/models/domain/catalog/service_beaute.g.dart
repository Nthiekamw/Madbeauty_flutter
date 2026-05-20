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
      description: json['description'] as String?,
      categorieId: json['categorie_id'] as String?,
      dureeMinutes: (json['duree_minutes'] as num?)?.toInt() ?? 60,
      prix: json['prix'] == null
          ? 0
          : const DecimalConverter().fromJson(json['prix']),
      isActif: json['is_actif'] as bool? ?? true,
    );

Map<String, dynamic> _$ServiceBeauteToJson(_ServiceBeaute instance) =>
    <String, dynamic>{
      'id': instance.id,
      'prestataire_id': instance.prestataireId,
      'nom': instance.nom,
      'description': instance.description,
      'categorie_id': instance.categorieId,
      'duree_minutes': instance.dureeMinutes,
      'prix': const DecimalConverter().toJson(instance.prix),
      'is_actif': instance.isActif,
    };

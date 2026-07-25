// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pack_offre.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PackOffre _$PackOffreFromJson(Map<String, dynamic> json) => _PackOffre(
  id: json['id'] as String,
  prestataireId: json['prestataire_id'] as String,
  titre: json['titre'] as String,
  description: json['description'] as String?,
  imageUrl: json['image_url'] as String?,
  prixPack: const DecimalConverter().fromJson(json['prix_pack']),
  isOffreDuJour: json['is_offre_du_jour'] as bool? ?? false,
  isActif: json['is_actif'] as bool? ?? false,
  startsAt: json['starts_at'] == null
      ? null
      : DateTime.parse(json['starts_at'] as String),
  endsAt: json['ends_at'] == null
      ? null
      : DateTime.parse(json['ends_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PackOffreToJson(_PackOffre instance) =>
    <String, dynamic>{
      'id': instance.id,
      'prestataire_id': instance.prestataireId,
      'titre': instance.titre,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'prix_pack': const DecimalConverter().toJson(instance.prixPack),
      'is_offre_du_jour': instance.isOffreDuJour,
      'is_actif': instance.isActif,
      'starts_at': instance.startsAt?.toIso8601String(),
      'ends_at': instance.endsAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

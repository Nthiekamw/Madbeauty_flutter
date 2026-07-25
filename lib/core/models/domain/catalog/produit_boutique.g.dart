// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produit_boutique.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProduitBoutique _$ProduitBoutiqueFromJson(Map<String, dynamic> json) =>
    _ProduitBoutique(
      id: json['id'] as String,
      prestataireId: json['prestataire_id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String?,
      conditionnement: json['conditionnement'] as String?,
      categorie:
          $enumDecodeNullable(
            _$ProduitBoutiqueCategorieEnumMap,
            json['categorie'],
          ) ??
          ProduitBoutiqueCategorie.autre,
      prix: json['prix'] == null
          ? 0
          : const DecimalConverter().fromJson(json['prix']),
      imageUrl: json['image_url'] as String?,
      isActif: json['is_actif'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ProduitBoutiqueToJson(_ProduitBoutique instance) =>
    <String, dynamic>{
      'id': instance.id,
      'prestataire_id': instance.prestataireId,
      'nom': instance.nom,
      'description': instance.description,
      'conditionnement': instance.conditionnement,
      'categorie': _$ProduitBoutiqueCategorieEnumMap[instance.categorie]!,
      'prix': const DecimalConverter().toJson(instance.prix),
      'image_url': instance.imageUrl,
      'is_actif': instance.isActif,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$ProduitBoutiqueCategorieEnumMap = {
  ProduitBoutiqueCategorie.cheveux: 'cheveux',
  ProduitBoutiqueCategorie.visage: 'visage',
  ProduitBoutiqueCategorie.corps: 'corps',
  ProduitBoutiqueCategorie.accessoires: 'accessoires',
  ProduitBoutiqueCategorie.autre: 'autre',
};

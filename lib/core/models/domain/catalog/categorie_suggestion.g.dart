// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categorie_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategorieSuggestion _$CategorieSuggestionFromJson(Map<String, dynamic> json) =>
    _CategorieSuggestion(
      id: json['id'] as String,
      prestataireId: json['prestataire_id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String?,
      createdAt: const IsoDateTimeConverter().fromJson(json['created_at']),
    );

Map<String, dynamic> _$CategorieSuggestionToJson(
  _CategorieSuggestion instance,
) => <String, dynamic>{
  'id': instance.id,
  'prestataire_id': instance.prestataireId,
  'nom': instance.nom,
  'description': instance.description,
  'created_at': const IsoDateTimeConverter().toJson(instance.createdAt),
};

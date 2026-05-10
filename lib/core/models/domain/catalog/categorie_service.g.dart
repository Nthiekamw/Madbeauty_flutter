// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categorie_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategorieService _$CategorieServiceFromJson(Map<String, dynamic> json) =>
    _CategorieService(
      id: json['id'] as String,
      nom: json['nom'] as String,
      icone: json['icone'] as String?,
    );

Map<String, dynamic> _$CategorieServiceToJson(_CategorieService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'icone': instance.icone,
    };

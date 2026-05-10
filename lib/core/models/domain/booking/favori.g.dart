// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favori.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Favori _$FavoriFromJson(Map<String, dynamic> json) => _Favori(
  clientId: json['client_id'] as String,
  prestataireId: json['prestataire_id'] as String,
  createdAt: const IsoDateTimeConverter().fromJson(json['created_at']),
);

Map<String, dynamic> _$FavoriToJson(_Favori instance) => <String, dynamic>{
  'client_id': instance.clientId,
  'prestataire_id': instance.prestataireId,
  'created_at': const IsoDateTimeConverter().toJson(instance.createdAt),
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Avis _$AvisFromJson(Map<String, dynamic> json) => _Avis(
  id: json['id'] as String,
  clientId: json['client_id'] as String,
  prestataireId: json['prestataire_id'] as String,
  reservationId: json['reservation_id'] as String,
  note: (json['note'] as num).toInt(),
  commentaire: json['commentaire'] as String?,
  photoUrls:
      (json['photo_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: const IsoDateTimeConverter().fromJson(json['created_at']),
);

Map<String, dynamic> _$AvisToJson(_Avis instance) => <String, dynamic>{
  'id': instance.id,
  'client_id': instance.clientId,
  'prestataire_id': instance.prestataireId,
  'reservation_id': instance.reservationId,
  'note': instance.note,
  'commentaire': instance.commentaire,
  'photo_urls': instance.photoUrls,
  'created_at': const IsoDateTimeConverter().toJson(instance.createdAt),
};

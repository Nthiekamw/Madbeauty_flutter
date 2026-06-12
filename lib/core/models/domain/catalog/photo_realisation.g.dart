// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_realisation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PhotoRealisation _$PhotoRealisationFromJson(Map<String, dynamic> json) =>
    _PhotoRealisation(
      id: json['id'] as String,
      prestataireId: json['prestataire_id'] as String,
      url: json['url'] as String,
      caption: json['caption'] as String?,
      categorieId: json['categorie_id'] as String?,
      mediaType:
          $enumDecodeNullable(
            _$RealisationMediaTypeEnumMap,
            json['media_type'],
          ) ??
          RealisationMediaType.image,
      createdAt: const IsoDateTimeConverter().fromJson(json['created_at']),
    );

Map<String, dynamic> _$PhotoRealisationToJson(_PhotoRealisation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'prestataire_id': instance.prestataireId,
      'url': instance.url,
      'caption': instance.caption,
      'categorie_id': instance.categorieId,
      'media_type': _$RealisationMediaTypeEnumMap[instance.mediaType]!,
      'created_at': const IsoDateTimeConverter().toJson(instance.createdAt),
    };

const _$RealisationMediaTypeEnumMap = {
  RealisationMediaType.image: 'image',
  RealisationMediaType.video: 'video',
};

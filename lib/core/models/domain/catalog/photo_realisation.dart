import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';
import 'realisation_media_type.dart';

part 'photo_realisation.freezed.dart';
part 'photo_realisation.g.dart';

/// [PHOTOS_REALISATION]
@freezed
abstract class PhotoRealisation with _$PhotoRealisation {
  const factory PhotoRealisation({
    required String id,
    required String prestataireId,
    required String url,
    String? caption,
    String? categorieId,
    @Default(RealisationMediaType.image)
    @JsonKey(name: 'media_type')
    RealisationMediaType mediaType,
    @IsoDateTimeConverter() required DateTime createdAt,
  }) = _PhotoRealisation;

  factory PhotoRealisation.fromJson(Map<String, dynamic> json) =>
      _$PhotoRealisationFromJson(json);
}

extension PhotoRealisationListX on List<PhotoRealisation> {
  /// Photos seules (cartes catalogue / accueil).
  List<PhotoRealisation> get realisationImagesOnly =>
      where((item) => item.mediaType.isImage).toList();
}


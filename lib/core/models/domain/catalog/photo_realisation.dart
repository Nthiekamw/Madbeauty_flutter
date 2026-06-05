import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';

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
    @IsoDateTimeConverter() required DateTime createdAt,
  }) = _PhotoRealisation;

  factory PhotoRealisation.fromJson(Map<String, dynamic> json) =>
      _$PhotoRealisationFromJson(json);
}


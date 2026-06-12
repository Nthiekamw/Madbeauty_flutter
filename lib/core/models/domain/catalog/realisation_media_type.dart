import 'package:freezed_annotation/freezed_annotation.dart';

part 'realisation_media_type.g.dart';

/// Type de média dans [PhotoRealisation] (table `photos_realisation.media_type`).
@JsonEnum(alwaysCreate: true)
enum RealisationMediaType {
  @JsonValue('image')
  image,
  @JsonValue('video')
  video,
}

extension RealisationMediaTypeX on RealisationMediaType {
  bool get isVideo => this == RealisationMediaType.video;
  bool get isImage => this == RealisationMediaType.image;
}

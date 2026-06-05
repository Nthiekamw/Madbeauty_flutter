import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';

part 'avis.freezed.dart';
part 'avis.g.dart';

/// [AVIS]
@freezed
abstract class Avis with _$Avis {
  const factory Avis({
    required String id,
    required String clientId,
    required String prestataireId,
    required String reservationId,
    required int note,
    String? commentaire,
    @JsonKey(name: 'photo_urls') @Default([]) List<String> photoUrls,
    @IsoDateTimeConverter() required DateTime createdAt,
  }) = _Avis;

  factory Avis.fromJson(Map<String, dynamic> json) => _$AvisFromJson(json);
}


import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';

part 'service_beaute.freezed.dart';
part 'service_beaute.g.dart';

/// [SERVICES_BEAUTE]
@freezed
abstract class ServiceBeaute with _$ServiceBeaute {
  const factory ServiceBeaute({
    required String id,
    required String prestataireId,
    required String nom,
    String? description,
    @JsonKey(name: 'categorie_id') String? categorieId,
    @Default(60) int dureeMinutes,
    @DecimalConverter() @Default(0) double prix,
    @Default(true) bool isActif,
  }) = _ServiceBeaute;

  factory ServiceBeaute.fromJson(Map<String, dynamic> json) =>
      _$ServiceBeauteFromJson(json);
}


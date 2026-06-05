import 'package:json_annotation/json_annotation.dart';

import 'lieu_travail.dart';

class LieuTravailConverter implements JsonConverter<LieuTravail?, String?> {
  const LieuTravailConverter();

  @override
  LieuTravail? fromJson(String? json) => LieuTravail.fromValue(json);

  @override
  String? toJson(LieuTravail? object) => object?.value;
}


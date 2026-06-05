import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';

part 'favori.freezed.dart';
part 'favori.g.dart';

/// [FAVORIS] – clé composite (client_id, prestataire_id).
@freezed
abstract class Favori with _$Favori {
  const factory Favori({
    required String clientId,
    required String prestataireId,
    @IsoDateTimeConverter() required DateTime createdAt,
  }) = _Favori;

  factory Favori.fromJson(Map<String, dynamic> json) => _$FavoriFromJson(json);
}


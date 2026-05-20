import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';

part 'categorie_suggestion.freezed.dart';
part 'categorie_suggestion.g.dart';

/// [SUGGESTIONS_CATEGORIE] — proposition de nouvelle catégorie de service.
@freezed
abstract class CategorieSuggestion with _$CategorieSuggestion {
  const factory CategorieSuggestion({
    required String id,
    @JsonKey(name: 'prestataire_id') required String prestataireId,
    required String nom,
    String? description,
    @JsonKey(name: 'created_at')
    @IsoDateTimeConverter()
    required DateTime createdAt,
  }) = _CategorieSuggestion;

  factory CategorieSuggestion.fromJson(Map<String, dynamic> json) =>
      _$CategorieSuggestionFromJson(json);
}

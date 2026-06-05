import 'package:freezed_annotation/freezed_annotation.dart';

part 'categorie_service.freezed.dart';
part 'categorie_service.g.dart';

/// [CATEGORIES_SERVICE]
@freezed
abstract class CategorieService with _$CategorieService {
  const factory CategorieService({
    required String id,
    required String nom,
    String? icone,
  }) = _CategorieService;

  factory CategorieService.fromJson(Map<String, dynamic> json) =>
      _$CategorieServiceFromJson(json);
}


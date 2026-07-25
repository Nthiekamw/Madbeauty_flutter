import 'package:freezed_annotation/freezed_annotation.dart';

import 'pack_item_type.dart';

part 'pack_item.freezed.dart';
part 'pack_item.g.dart';

class PackItemTypeConverter implements JsonConverter<PackItemType, String> {
  const PackItemTypeConverter();

  @override
  PackItemType fromJson(String json) => PackItemType.fromDb(json);

  @override
  String toJson(PackItemType object) => object.dbValue;
}

/// [PACK_ITEMS]
@freezed
abstract class PackItem with _$PackItem {
  const factory PackItem({
    required String id,
    required String packId,
    @PackItemTypeConverter() required PackItemType itemType,
    String? serviceId,
    String? produitId,
    @Default(1) int quantite,
    @Default(0) int sortOrder,
  }) = _PackItem;

  factory PackItem.fromJson(Map<String, dynamic> json) =>
      _$PackItemFromJson(json);
}

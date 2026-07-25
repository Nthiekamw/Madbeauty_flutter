// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pack_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PackItem _$PackItemFromJson(Map<String, dynamic> json) => _PackItem(
  id: json['id'] as String,
  packId: json['pack_id'] as String,
  itemType: const PackItemTypeConverter().fromJson(json['item_type'] as String),
  serviceId: json['service_id'] as String?,
  produitId: json['produit_id'] as String?,
  quantite: (json['quantite'] as num?)?.toInt() ?? 1,
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PackItemToJson(_PackItem instance) => <String, dynamic>{
  'id': instance.id,
  'pack_id': instance.packId,
  'item_type': const PackItemTypeConverter().toJson(instance.itemType),
  'service_id': instance.serviceId,
  'produit_id': instance.produitId,
  'quantite': instance.quantite,
  'sort_order': instance.sortOrder,
};

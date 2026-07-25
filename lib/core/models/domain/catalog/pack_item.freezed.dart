// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pack_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PackItem {

 String get id; String get packId;@PackItemTypeConverter() PackItemType get itemType; String? get serviceId; String? get produitId; int get quantite; int get sortOrder;
/// Create a copy of PackItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackItemCopyWith<PackItem> get copyWith => _$PackItemCopyWithImpl<PackItem>(this as PackItem, _$identity);

  /// Serializes this PackItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackItem&&(identical(other.id, id) || other.id == id)&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.produitId, produitId) || other.produitId == produitId)&&(identical(other.quantite, quantite) || other.quantite == quantite)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,packId,itemType,serviceId,produitId,quantite,sortOrder);

@override
String toString() {
  return 'PackItem(id: $id, packId: $packId, itemType: $itemType, serviceId: $serviceId, produitId: $produitId, quantite: $quantite, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $PackItemCopyWith<$Res>  {
  factory $PackItemCopyWith(PackItem value, $Res Function(PackItem) _then) = _$PackItemCopyWithImpl;
@useResult
$Res call({
 String id, String packId,@PackItemTypeConverter() PackItemType itemType, String? serviceId, String? produitId, int quantite, int sortOrder
});




}
/// @nodoc
class _$PackItemCopyWithImpl<$Res>
    implements $PackItemCopyWith<$Res> {
  _$PackItemCopyWithImpl(this._self, this._then);

  final PackItem _self;
  final $Res Function(PackItem) _then;

/// Create a copy of PackItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? packId = null,Object? itemType = null,Object? serviceId = freezed,Object? produitId = freezed,Object? quantite = null,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as PackItemType,serviceId: freezed == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String?,produitId: freezed == produitId ? _self.produitId : produitId // ignore: cast_nullable_to_non_nullable
as String?,quantite: null == quantite ? _self.quantite : quantite // ignore: cast_nullable_to_non_nullable
as int,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PackItem].
extension PackItemPatterns on PackItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackItem value)  $default,){
final _that = this;
switch (_that) {
case _PackItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackItem value)?  $default,){
final _that = this;
switch (_that) {
case _PackItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String packId, @PackItemTypeConverter()  PackItemType itemType,  String? serviceId,  String? produitId,  int quantite,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackItem() when $default != null:
return $default(_that.id,_that.packId,_that.itemType,_that.serviceId,_that.produitId,_that.quantite,_that.sortOrder);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String packId, @PackItemTypeConverter()  PackItemType itemType,  String? serviceId,  String? produitId,  int quantite,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _PackItem():
return $default(_that.id,_that.packId,_that.itemType,_that.serviceId,_that.produitId,_that.quantite,_that.sortOrder);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String packId, @PackItemTypeConverter()  PackItemType itemType,  String? serviceId,  String? produitId,  int quantite,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _PackItem() when $default != null:
return $default(_that.id,_that.packId,_that.itemType,_that.serviceId,_that.produitId,_that.quantite,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackItem implements PackItem {
  const _PackItem({required this.id, required this.packId, @PackItemTypeConverter() required this.itemType, this.serviceId, this.produitId, this.quantite = 1, this.sortOrder = 0});
  factory _PackItem.fromJson(Map<String, dynamic> json) => _$PackItemFromJson(json);

@override final  String id;
@override final  String packId;
@override@PackItemTypeConverter() final  PackItemType itemType;
@override final  String? serviceId;
@override final  String? produitId;
@override@JsonKey() final  int quantite;
@override@JsonKey() final  int sortOrder;

/// Create a copy of PackItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackItemCopyWith<_PackItem> get copyWith => __$PackItemCopyWithImpl<_PackItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackItem&&(identical(other.id, id) || other.id == id)&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.itemType, itemType) || other.itemType == itemType)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.produitId, produitId) || other.produitId == produitId)&&(identical(other.quantite, quantite) || other.quantite == quantite)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,packId,itemType,serviceId,produitId,quantite,sortOrder);

@override
String toString() {
  return 'PackItem(id: $id, packId: $packId, itemType: $itemType, serviceId: $serviceId, produitId: $produitId, quantite: $quantite, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$PackItemCopyWith<$Res> implements $PackItemCopyWith<$Res> {
  factory _$PackItemCopyWith(_PackItem value, $Res Function(_PackItem) _then) = __$PackItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String packId,@PackItemTypeConverter() PackItemType itemType, String? serviceId, String? produitId, int quantite, int sortOrder
});




}
/// @nodoc
class __$PackItemCopyWithImpl<$Res>
    implements _$PackItemCopyWith<$Res> {
  __$PackItemCopyWithImpl(this._self, this._then);

  final _PackItem _self;
  final $Res Function(_PackItem) _then;

/// Create a copy of PackItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? packId = null,Object? itemType = null,Object? serviceId = freezed,Object? produitId = freezed,Object? quantite = null,Object? sortOrder = null,}) {
  return _then(_PackItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,itemType: null == itemType ? _self.itemType : itemType // ignore: cast_nullable_to_non_nullable
as PackItemType,serviceId: freezed == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String?,produitId: freezed == produitId ? _self.produitId : produitId // ignore: cast_nullable_to_non_nullable
as String?,quantite: null == quantite ? _self.quantite : quantite // ignore: cast_nullable_to_non_nullable
as int,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pack_offre.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PackOffre {

 String get id; String get prestataireId; String get titre; String? get description; String? get imageUrl;@DecimalConverter() double get prixPack; bool get isOffreDuJour; bool get isActif; DateTime? get startsAt; DateTime? get endsAt; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of PackOffre
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackOffreCopyWith<PackOffre> get copyWith => _$PackOffreCopyWithImpl<PackOffre>(this as PackOffre, _$identity);

  /// Serializes this PackOffre to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackOffre&&(identical(other.id, id) || other.id == id)&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.titre, titre) || other.titre == titre)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.prixPack, prixPack) || other.prixPack == prixPack)&&(identical(other.isOffreDuJour, isOffreDuJour) || other.isOffreDuJour == isOffreDuJour)&&(identical(other.isActif, isActif) || other.isActif == isActif)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,prestataireId,titre,description,imageUrl,prixPack,isOffreDuJour,isActif,startsAt,endsAt,createdAt,updatedAt);

@override
String toString() {
  return 'PackOffre(id: $id, prestataireId: $prestataireId, titre: $titre, description: $description, imageUrl: $imageUrl, prixPack: $prixPack, isOffreDuJour: $isOffreDuJour, isActif: $isActif, startsAt: $startsAt, endsAt: $endsAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PackOffreCopyWith<$Res>  {
  factory $PackOffreCopyWith(PackOffre value, $Res Function(PackOffre) _then) = _$PackOffreCopyWithImpl;
@useResult
$Res call({
 String id, String prestataireId, String titre, String? description, String? imageUrl,@DecimalConverter() double prixPack, bool isOffreDuJour, bool isActif, DateTime? startsAt, DateTime? endsAt, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$PackOffreCopyWithImpl<$Res>
    implements $PackOffreCopyWith<$Res> {
  _$PackOffreCopyWithImpl(this._self, this._then);

  final PackOffre _self;
  final $Res Function(PackOffre) _then;

/// Create a copy of PackOffre
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? prestataireId = null,Object? titre = null,Object? description = freezed,Object? imageUrl = freezed,Object? prixPack = null,Object? isOffreDuJour = null,Object? isActif = null,Object? startsAt = freezed,Object? endsAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,titre: null == titre ? _self.titre : titre // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,prixPack: null == prixPack ? _self.prixPack : prixPack // ignore: cast_nullable_to_non_nullable
as double,isOffreDuJour: null == isOffreDuJour ? _self.isOffreDuJour : isOffreDuJour // ignore: cast_nullable_to_non_nullable
as bool,isActif: null == isActif ? _self.isActif : isActif // ignore: cast_nullable_to_non_nullable
as bool,startsAt: freezed == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PackOffre].
extension PackOffrePatterns on PackOffre {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackOffre value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackOffre() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackOffre value)  $default,){
final _that = this;
switch (_that) {
case _PackOffre():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackOffre value)?  $default,){
final _that = this;
switch (_that) {
case _PackOffre() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String prestataireId,  String titre,  String? description,  String? imageUrl, @DecimalConverter()  double prixPack,  bool isOffreDuJour,  bool isActif,  DateTime? startsAt,  DateTime? endsAt,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackOffre() when $default != null:
return $default(_that.id,_that.prestataireId,_that.titre,_that.description,_that.imageUrl,_that.prixPack,_that.isOffreDuJour,_that.isActif,_that.startsAt,_that.endsAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String prestataireId,  String titre,  String? description,  String? imageUrl, @DecimalConverter()  double prixPack,  bool isOffreDuJour,  bool isActif,  DateTime? startsAt,  DateTime? endsAt,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PackOffre():
return $default(_that.id,_that.prestataireId,_that.titre,_that.description,_that.imageUrl,_that.prixPack,_that.isOffreDuJour,_that.isActif,_that.startsAt,_that.endsAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String prestataireId,  String titre,  String? description,  String? imageUrl, @DecimalConverter()  double prixPack,  bool isOffreDuJour,  bool isActif,  DateTime? startsAt,  DateTime? endsAt,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PackOffre() when $default != null:
return $default(_that.id,_that.prestataireId,_that.titre,_that.description,_that.imageUrl,_that.prixPack,_that.isOffreDuJour,_that.isActif,_that.startsAt,_that.endsAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackOffre implements PackOffre {
  const _PackOffre({required this.id, required this.prestataireId, required this.titre, this.description, this.imageUrl, @DecimalConverter() required this.prixPack, this.isOffreDuJour = false, this.isActif = false, this.startsAt, this.endsAt, this.createdAt, this.updatedAt});
  factory _PackOffre.fromJson(Map<String, dynamic> json) => _$PackOffreFromJson(json);

@override final  String id;
@override final  String prestataireId;
@override final  String titre;
@override final  String? description;
@override final  String? imageUrl;
@override@DecimalConverter() final  double prixPack;
@override@JsonKey() final  bool isOffreDuJour;
@override@JsonKey() final  bool isActif;
@override final  DateTime? startsAt;
@override final  DateTime? endsAt;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of PackOffre
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackOffreCopyWith<_PackOffre> get copyWith => __$PackOffreCopyWithImpl<_PackOffre>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackOffreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackOffre&&(identical(other.id, id) || other.id == id)&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.titre, titre) || other.titre == titre)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.prixPack, prixPack) || other.prixPack == prixPack)&&(identical(other.isOffreDuJour, isOffreDuJour) || other.isOffreDuJour == isOffreDuJour)&&(identical(other.isActif, isActif) || other.isActif == isActif)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,prestataireId,titre,description,imageUrl,prixPack,isOffreDuJour,isActif,startsAt,endsAt,createdAt,updatedAt);

@override
String toString() {
  return 'PackOffre(id: $id, prestataireId: $prestataireId, titre: $titre, description: $description, imageUrl: $imageUrl, prixPack: $prixPack, isOffreDuJour: $isOffreDuJour, isActif: $isActif, startsAt: $startsAt, endsAt: $endsAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PackOffreCopyWith<$Res> implements $PackOffreCopyWith<$Res> {
  factory _$PackOffreCopyWith(_PackOffre value, $Res Function(_PackOffre) _then) = __$PackOffreCopyWithImpl;
@override @useResult
$Res call({
 String id, String prestataireId, String titre, String? description, String? imageUrl,@DecimalConverter() double prixPack, bool isOffreDuJour, bool isActif, DateTime? startsAt, DateTime? endsAt, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$PackOffreCopyWithImpl<$Res>
    implements _$PackOffreCopyWith<$Res> {
  __$PackOffreCopyWithImpl(this._self, this._then);

  final _PackOffre _self;
  final $Res Function(_PackOffre) _then;

/// Create a copy of PackOffre
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? prestataireId = null,Object? titre = null,Object? description = freezed,Object? imageUrl = freezed,Object? prixPack = null,Object? isOffreDuJour = null,Object? isActif = null,Object? startsAt = freezed,Object? endsAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_PackOffre(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,titre: null == titre ? _self.titre : titre // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,prixPack: null == prixPack ? _self.prixPack : prixPack // ignore: cast_nullable_to_non_nullable
as double,isOffreDuJour: null == isOffreDuJour ? _self.isOffreDuJour : isOffreDuJour // ignore: cast_nullable_to_non_nullable
as bool,isActif: null == isActif ? _self.isActif : isActif // ignore: cast_nullable_to_non_nullable
as bool,startsAt: freezed == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

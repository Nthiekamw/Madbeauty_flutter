// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_realisation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PhotoRealisation {

 String get id; String get prestataireId; String get url; String? get caption; String? get categorieId;@IsoDateTimeConverter() DateTime get createdAt;
/// Create a copy of PhotoRealisation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoRealisationCopyWith<PhotoRealisation> get copyWith => _$PhotoRealisationCopyWithImpl<PhotoRealisation>(this as PhotoRealisation, _$identity);

  /// Serializes this PhotoRealisation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoRealisation&&(identical(other.id, id) || other.id == id)&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.url, url) || other.url == url)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.categorieId, categorieId) || other.categorieId == categorieId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,prestataireId,url,caption,categorieId,createdAt);

@override
String toString() {
  return 'PhotoRealisation(id: $id, prestataireId: $prestataireId, url: $url, caption: $caption, categorieId: $categorieId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PhotoRealisationCopyWith<$Res>  {
  factory $PhotoRealisationCopyWith(PhotoRealisation value, $Res Function(PhotoRealisation) _then) = _$PhotoRealisationCopyWithImpl;
@useResult
$Res call({
 String id, String prestataireId, String url, String? caption, String? categorieId,@IsoDateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class _$PhotoRealisationCopyWithImpl<$Res>
    implements $PhotoRealisationCopyWith<$Res> {
  _$PhotoRealisationCopyWithImpl(this._self, this._then);

  final PhotoRealisation _self;
  final $Res Function(PhotoRealisation) _then;

/// Create a copy of PhotoRealisation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? prestataireId = null,Object? url = null,Object? caption = freezed,Object? categorieId = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,categorieId: freezed == categorieId ? _self.categorieId : categorieId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoRealisation].
extension PhotoRealisationPatterns on PhotoRealisation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoRealisation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoRealisation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoRealisation value)  $default,){
final _that = this;
switch (_that) {
case _PhotoRealisation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoRealisation value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoRealisation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String prestataireId,  String url,  String? caption,  String? categorieId, @IsoDateTimeConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoRealisation() when $default != null:
return $default(_that.id,_that.prestataireId,_that.url,_that.caption,_that.categorieId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String prestataireId,  String url,  String? caption,  String? categorieId, @IsoDateTimeConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PhotoRealisation():
return $default(_that.id,_that.prestataireId,_that.url,_that.caption,_that.categorieId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String prestataireId,  String url,  String? caption,  String? categorieId, @IsoDateTimeConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PhotoRealisation() when $default != null:
return $default(_that.id,_that.prestataireId,_that.url,_that.caption,_that.categorieId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PhotoRealisation implements PhotoRealisation {
  const _PhotoRealisation({required this.id, required this.prestataireId, required this.url, this.caption, this.categorieId, @IsoDateTimeConverter() required this.createdAt});
  factory _PhotoRealisation.fromJson(Map<String, dynamic> json) => _$PhotoRealisationFromJson(json);

@override final  String id;
@override final  String prestataireId;
@override final  String url;
@override final  String? caption;
@override final  String? categorieId;
@override@IsoDateTimeConverter() final  DateTime createdAt;

/// Create a copy of PhotoRealisation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoRealisationCopyWith<_PhotoRealisation> get copyWith => __$PhotoRealisationCopyWithImpl<_PhotoRealisation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotoRealisationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoRealisation&&(identical(other.id, id) || other.id == id)&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.url, url) || other.url == url)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.categorieId, categorieId) || other.categorieId == categorieId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,prestataireId,url,caption,categorieId,createdAt);

@override
String toString() {
  return 'PhotoRealisation(id: $id, prestataireId: $prestataireId, url: $url, caption: $caption, categorieId: $categorieId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PhotoRealisationCopyWith<$Res> implements $PhotoRealisationCopyWith<$Res> {
  factory _$PhotoRealisationCopyWith(_PhotoRealisation value, $Res Function(_PhotoRealisation) _then) = __$PhotoRealisationCopyWithImpl;
@override @useResult
$Res call({
 String id, String prestataireId, String url, String? caption, String? categorieId,@IsoDateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class __$PhotoRealisationCopyWithImpl<$Res>
    implements _$PhotoRealisationCopyWith<$Res> {
  __$PhotoRealisationCopyWithImpl(this._self, this._then);

  final _PhotoRealisation _self;
  final $Res Function(_PhotoRealisation) _then;

/// Create a copy of PhotoRealisation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? prestataireId = null,Object? url = null,Object? caption = freezed,Object? categorieId = freezed,Object? createdAt = null,}) {
  return _then(_PhotoRealisation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,categorieId: freezed == categorieId ? _self.categorieId : categorieId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

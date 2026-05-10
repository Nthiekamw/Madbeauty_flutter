// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favori.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Favori {

 String get clientId; String get prestataireId;@IsoDateTimeConverter() DateTime get createdAt;
/// Create a copy of Favori
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriCopyWith<Favori> get copyWith => _$FavoriCopyWithImpl<Favori>(this as Favori, _$identity);

  /// Serializes this Favori to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Favori&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientId,prestataireId,createdAt);

@override
String toString() {
  return 'Favori(clientId: $clientId, prestataireId: $prestataireId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FavoriCopyWith<$Res>  {
  factory $FavoriCopyWith(Favori value, $Res Function(Favori) _then) = _$FavoriCopyWithImpl;
@useResult
$Res call({
 String clientId, String prestataireId,@IsoDateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class _$FavoriCopyWithImpl<$Res>
    implements $FavoriCopyWith<$Res> {
  _$FavoriCopyWithImpl(this._self, this._then);

  final Favori _self;
  final $Res Function(Favori) _then;

/// Create a copy of Favori
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientId = null,Object? prestataireId = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Favori].
extension FavoriPatterns on Favori {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Favori value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Favori() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Favori value)  $default,){
final _that = this;
switch (_that) {
case _Favori():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Favori value)?  $default,){
final _that = this;
switch (_that) {
case _Favori() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String clientId,  String prestataireId, @IsoDateTimeConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Favori() when $default != null:
return $default(_that.clientId,_that.prestataireId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String clientId,  String prestataireId, @IsoDateTimeConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Favori():
return $default(_that.clientId,_that.prestataireId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String clientId,  String prestataireId, @IsoDateTimeConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Favori() when $default != null:
return $default(_that.clientId,_that.prestataireId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Favori implements Favori {
  const _Favori({required this.clientId, required this.prestataireId, @IsoDateTimeConverter() required this.createdAt});
  factory _Favori.fromJson(Map<String, dynamic> json) => _$FavoriFromJson(json);

@override final  String clientId;
@override final  String prestataireId;
@override@IsoDateTimeConverter() final  DateTime createdAt;

/// Create a copy of Favori
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriCopyWith<_Favori> get copyWith => __$FavoriCopyWithImpl<_Favori>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FavoriToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Favori&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientId,prestataireId,createdAt);

@override
String toString() {
  return 'Favori(clientId: $clientId, prestataireId: $prestataireId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FavoriCopyWith<$Res> implements $FavoriCopyWith<$Res> {
  factory _$FavoriCopyWith(_Favori value, $Res Function(_Favori) _then) = __$FavoriCopyWithImpl;
@override @useResult
$Res call({
 String clientId, String prestataireId,@IsoDateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class __$FavoriCopyWithImpl<$Res>
    implements _$FavoriCopyWith<$Res> {
  __$FavoriCopyWithImpl(this._self, this._then);

  final _Favori _self;
  final $Res Function(_Favori) _then;

/// Create a copy of Favori
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientId = null,Object? prestataireId = null,Object? createdAt = null,}) {
  return _then(_Favori(
clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

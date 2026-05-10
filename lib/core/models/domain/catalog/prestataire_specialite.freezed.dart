// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prestataire_specialite.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrestataireSpecialite {

 String get prestataireId; String get categorieId;
/// Create a copy of PrestataireSpecialite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrestataireSpecialiteCopyWith<PrestataireSpecialite> get copyWith => _$PrestataireSpecialiteCopyWithImpl<PrestataireSpecialite>(this as PrestataireSpecialite, _$identity);

  /// Serializes this PrestataireSpecialite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrestataireSpecialite&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.categorieId, categorieId) || other.categorieId == categorieId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prestataireId,categorieId);

@override
String toString() {
  return 'PrestataireSpecialite(prestataireId: $prestataireId, categorieId: $categorieId)';
}


}

/// @nodoc
abstract mixin class $PrestataireSpecialiteCopyWith<$Res>  {
  factory $PrestataireSpecialiteCopyWith(PrestataireSpecialite value, $Res Function(PrestataireSpecialite) _then) = _$PrestataireSpecialiteCopyWithImpl;
@useResult
$Res call({
 String prestataireId, String categorieId
});




}
/// @nodoc
class _$PrestataireSpecialiteCopyWithImpl<$Res>
    implements $PrestataireSpecialiteCopyWith<$Res> {
  _$PrestataireSpecialiteCopyWithImpl(this._self, this._then);

  final PrestataireSpecialite _self;
  final $Res Function(PrestataireSpecialite) _then;

/// Create a copy of PrestataireSpecialite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? prestataireId = null,Object? categorieId = null,}) {
  return _then(_self.copyWith(
prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,categorieId: null == categorieId ? _self.categorieId : categorieId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PrestataireSpecialite].
extension PrestataireSpecialitePatterns on PrestataireSpecialite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrestataireSpecialite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrestataireSpecialite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrestataireSpecialite value)  $default,){
final _that = this;
switch (_that) {
case _PrestataireSpecialite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrestataireSpecialite value)?  $default,){
final _that = this;
switch (_that) {
case _PrestataireSpecialite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String prestataireId,  String categorieId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrestataireSpecialite() when $default != null:
return $default(_that.prestataireId,_that.categorieId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String prestataireId,  String categorieId)  $default,) {final _that = this;
switch (_that) {
case _PrestataireSpecialite():
return $default(_that.prestataireId,_that.categorieId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String prestataireId,  String categorieId)?  $default,) {final _that = this;
switch (_that) {
case _PrestataireSpecialite() when $default != null:
return $default(_that.prestataireId,_that.categorieId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrestataireSpecialite implements PrestataireSpecialite {
  const _PrestataireSpecialite({required this.prestataireId, required this.categorieId});
  factory _PrestataireSpecialite.fromJson(Map<String, dynamic> json) => _$PrestataireSpecialiteFromJson(json);

@override final  String prestataireId;
@override final  String categorieId;

/// Create a copy of PrestataireSpecialite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrestataireSpecialiteCopyWith<_PrestataireSpecialite> get copyWith => __$PrestataireSpecialiteCopyWithImpl<_PrestataireSpecialite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrestataireSpecialiteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrestataireSpecialite&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.categorieId, categorieId) || other.categorieId == categorieId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prestataireId,categorieId);

@override
String toString() {
  return 'PrestataireSpecialite(prestataireId: $prestataireId, categorieId: $categorieId)';
}


}

/// @nodoc
abstract mixin class _$PrestataireSpecialiteCopyWith<$Res> implements $PrestataireSpecialiteCopyWith<$Res> {
  factory _$PrestataireSpecialiteCopyWith(_PrestataireSpecialite value, $Res Function(_PrestataireSpecialite) _then) = __$PrestataireSpecialiteCopyWithImpl;
@override @useResult
$Res call({
 String prestataireId, String categorieId
});




}
/// @nodoc
class __$PrestataireSpecialiteCopyWithImpl<$Res>
    implements _$PrestataireSpecialiteCopyWith<$Res> {
  __$PrestataireSpecialiteCopyWithImpl(this._self, this._then);

  final _PrestataireSpecialite _self;
  final $Res Function(_PrestataireSpecialite) _then;

/// Create a copy of PrestataireSpecialite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? prestataireId = null,Object? categorieId = null,}) {
  return _then(_PrestataireSpecialite(
prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,categorieId: null == categorieId ? _self.categorieId : categorieId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

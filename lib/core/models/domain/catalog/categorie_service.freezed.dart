// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'categorie_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CategorieService {

 String get id; String get nom; String? get icone;
/// Create a copy of CategorieService
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategorieServiceCopyWith<CategorieService> get copyWith => _$CategorieServiceCopyWithImpl<CategorieService>(this as CategorieService, _$identity);

  /// Serializes this CategorieService to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategorieService&&(identical(other.id, id) || other.id == id)&&(identical(other.nom, nom) || other.nom == nom)&&(identical(other.icone, icone) || other.icone == icone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nom,icone);

@override
String toString() {
  return 'CategorieService(id: $id, nom: $nom, icone: $icone)';
}


}

/// @nodoc
abstract mixin class $CategorieServiceCopyWith<$Res>  {
  factory $CategorieServiceCopyWith(CategorieService value, $Res Function(CategorieService) _then) = _$CategorieServiceCopyWithImpl;
@useResult
$Res call({
 String id, String nom, String? icone
});




}
/// @nodoc
class _$CategorieServiceCopyWithImpl<$Res>
    implements $CategorieServiceCopyWith<$Res> {
  _$CategorieServiceCopyWithImpl(this._self, this._then);

  final CategorieService _self;
  final $Res Function(CategorieService) _then;

/// Create a copy of CategorieService
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nom = null,Object? icone = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nom: null == nom ? _self.nom : nom // ignore: cast_nullable_to_non_nullable
as String,icone: freezed == icone ? _self.icone : icone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CategorieService].
extension CategorieServicePatterns on CategorieService {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategorieService value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategorieService() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategorieService value)  $default,){
final _that = this;
switch (_that) {
case _CategorieService():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategorieService value)?  $default,){
final _that = this;
switch (_that) {
case _CategorieService() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nom,  String? icone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategorieService() when $default != null:
return $default(_that.id,_that.nom,_that.icone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nom,  String? icone)  $default,) {final _that = this;
switch (_that) {
case _CategorieService():
return $default(_that.id,_that.nom,_that.icone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nom,  String? icone)?  $default,) {final _that = this;
switch (_that) {
case _CategorieService() when $default != null:
return $default(_that.id,_that.nom,_that.icone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategorieService implements CategorieService {
  const _CategorieService({required this.id, required this.nom, this.icone});
  factory _CategorieService.fromJson(Map<String, dynamic> json) => _$CategorieServiceFromJson(json);

@override final  String id;
@override final  String nom;
@override final  String? icone;

/// Create a copy of CategorieService
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategorieServiceCopyWith<_CategorieService> get copyWith => __$CategorieServiceCopyWithImpl<_CategorieService>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategorieServiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategorieService&&(identical(other.id, id) || other.id == id)&&(identical(other.nom, nom) || other.nom == nom)&&(identical(other.icone, icone) || other.icone == icone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nom,icone);

@override
String toString() {
  return 'CategorieService(id: $id, nom: $nom, icone: $icone)';
}


}

/// @nodoc
abstract mixin class _$CategorieServiceCopyWith<$Res> implements $CategorieServiceCopyWith<$Res> {
  factory _$CategorieServiceCopyWith(_CategorieService value, $Res Function(_CategorieService) _then) = __$CategorieServiceCopyWithImpl;
@override @useResult
$Res call({
 String id, String nom, String? icone
});




}
/// @nodoc
class __$CategorieServiceCopyWithImpl<$Res>
    implements _$CategorieServiceCopyWith<$Res> {
  __$CategorieServiceCopyWithImpl(this._self, this._then);

  final _CategorieService _self;
  final $Res Function(_CategorieService) _then;

/// Create a copy of CategorieService
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nom = null,Object? icone = freezed,}) {
  return _then(_CategorieService(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nom: null == nom ? _self.nom : nom // ignore: cast_nullable_to_non_nullable
as String,icone: freezed == icone ? _self.icone : icone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

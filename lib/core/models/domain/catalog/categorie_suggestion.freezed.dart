// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'categorie_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CategorieSuggestion {

 String get id;@JsonKey(name: 'prestataire_id') String get prestataireId; String get nom; String? get description;@JsonKey(name: 'created_at')@IsoDateTimeConverter() DateTime get createdAt;
/// Create a copy of CategorieSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategorieSuggestionCopyWith<CategorieSuggestion> get copyWith => _$CategorieSuggestionCopyWithImpl<CategorieSuggestion>(this as CategorieSuggestion, _$identity);

  /// Serializes this CategorieSuggestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategorieSuggestion&&(identical(other.id, id) || other.id == id)&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.nom, nom) || other.nom == nom)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,prestataireId,nom,description,createdAt);

@override
String toString() {
  return 'CategorieSuggestion(id: $id, prestataireId: $prestataireId, nom: $nom, description: $description, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CategorieSuggestionCopyWith<$Res>  {
  factory $CategorieSuggestionCopyWith(CategorieSuggestion value, $Res Function(CategorieSuggestion) _then) = _$CategorieSuggestionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'prestataire_id') String prestataireId, String nom, String? description,@JsonKey(name: 'created_at')@IsoDateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class _$CategorieSuggestionCopyWithImpl<$Res>
    implements $CategorieSuggestionCopyWith<$Res> {
  _$CategorieSuggestionCopyWithImpl(this._self, this._then);

  final CategorieSuggestion _self;
  final $Res Function(CategorieSuggestion) _then;

/// Create a copy of CategorieSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? prestataireId = null,Object? nom = null,Object? description = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,nom: null == nom ? _self.nom : nom // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CategorieSuggestion].
extension CategorieSuggestionPatterns on CategorieSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategorieSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategorieSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategorieSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _CategorieSuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategorieSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _CategorieSuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'prestataire_id')  String prestataireId,  String nom,  String? description, @JsonKey(name: 'created_at')@IsoDateTimeConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategorieSuggestion() when $default != null:
return $default(_that.id,_that.prestataireId,_that.nom,_that.description,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'prestataire_id')  String prestataireId,  String nom,  String? description, @JsonKey(name: 'created_at')@IsoDateTimeConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _CategorieSuggestion():
return $default(_that.id,_that.prestataireId,_that.nom,_that.description,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'prestataire_id')  String prestataireId,  String nom,  String? description, @JsonKey(name: 'created_at')@IsoDateTimeConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CategorieSuggestion() when $default != null:
return $default(_that.id,_that.prestataireId,_that.nom,_that.description,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategorieSuggestion implements CategorieSuggestion {
  const _CategorieSuggestion({required this.id, @JsonKey(name: 'prestataire_id') required this.prestataireId, required this.nom, this.description, @JsonKey(name: 'created_at')@IsoDateTimeConverter() required this.createdAt});
  factory _CategorieSuggestion.fromJson(Map<String, dynamic> json) => _$CategorieSuggestionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'prestataire_id') final  String prestataireId;
@override final  String nom;
@override final  String? description;
@override@JsonKey(name: 'created_at')@IsoDateTimeConverter() final  DateTime createdAt;

/// Create a copy of CategorieSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategorieSuggestionCopyWith<_CategorieSuggestion> get copyWith => __$CategorieSuggestionCopyWithImpl<_CategorieSuggestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategorieSuggestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategorieSuggestion&&(identical(other.id, id) || other.id == id)&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.nom, nom) || other.nom == nom)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,prestataireId,nom,description,createdAt);

@override
String toString() {
  return 'CategorieSuggestion(id: $id, prestataireId: $prestataireId, nom: $nom, description: $description, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CategorieSuggestionCopyWith<$Res> implements $CategorieSuggestionCopyWith<$Res> {
  factory _$CategorieSuggestionCopyWith(_CategorieSuggestion value, $Res Function(_CategorieSuggestion) _then) = __$CategorieSuggestionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'prestataire_id') String prestataireId, String nom, String? description,@JsonKey(name: 'created_at')@IsoDateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class __$CategorieSuggestionCopyWithImpl<$Res>
    implements _$CategorieSuggestionCopyWith<$Res> {
  __$CategorieSuggestionCopyWithImpl(this._self, this._then);

  final _CategorieSuggestion _self;
  final $Res Function(_CategorieSuggestion) _then;

/// Create a copy of CategorieSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? prestataireId = null,Object? nom = null,Object? description = freezed,Object? createdAt = null,}) {
  return _then(_CategorieSuggestion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,nom: null == nom ? _self.nom : nom // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

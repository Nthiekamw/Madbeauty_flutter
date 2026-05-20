// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_beaute.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ServiceBeaute {

 String get id; String get prestataireId; String get nom; String? get description;@JsonKey(name: 'categorie_id') String? get categorieId; int get dureeMinutes;@DecimalConverter() double get prix; bool get isActif;
/// Create a copy of ServiceBeaute
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceBeauteCopyWith<ServiceBeaute> get copyWith => _$ServiceBeauteCopyWithImpl<ServiceBeaute>(this as ServiceBeaute, _$identity);

  /// Serializes this ServiceBeaute to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceBeaute&&(identical(other.id, id) || other.id == id)&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.nom, nom) || other.nom == nom)&&(identical(other.description, description) || other.description == description)&&(identical(other.categorieId, categorieId) || other.categorieId == categorieId)&&(identical(other.dureeMinutes, dureeMinutes) || other.dureeMinutes == dureeMinutes)&&(identical(other.prix, prix) || other.prix == prix)&&(identical(other.isActif, isActif) || other.isActif == isActif));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,prestataireId,nom,description,categorieId,dureeMinutes,prix,isActif);

@override
String toString() {
  return 'ServiceBeaute(id: $id, prestataireId: $prestataireId, nom: $nom, description: $description, categorieId: $categorieId, dureeMinutes: $dureeMinutes, prix: $prix, isActif: $isActif)';
}


}

/// @nodoc
abstract mixin class $ServiceBeauteCopyWith<$Res>  {
  factory $ServiceBeauteCopyWith(ServiceBeaute value, $Res Function(ServiceBeaute) _then) = _$ServiceBeauteCopyWithImpl;
@useResult
$Res call({
 String id, String prestataireId, String nom, String? description,@JsonKey(name: 'categorie_id') String? categorieId, int dureeMinutes,@DecimalConverter() double prix, bool isActif
});




}
/// @nodoc
class _$ServiceBeauteCopyWithImpl<$Res>
    implements $ServiceBeauteCopyWith<$Res> {
  _$ServiceBeauteCopyWithImpl(this._self, this._then);

  final ServiceBeaute _self;
  final $Res Function(ServiceBeaute) _then;

/// Create a copy of ServiceBeaute
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? prestataireId = null,Object? nom = null,Object? description = freezed,Object? categorieId = freezed,Object? dureeMinutes = null,Object? prix = null,Object? isActif = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,nom: null == nom ? _self.nom : nom // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categorieId: freezed == categorieId ? _self.categorieId : categorieId // ignore: cast_nullable_to_non_nullable
as String?,dureeMinutes: null == dureeMinutes ? _self.dureeMinutes : dureeMinutes // ignore: cast_nullable_to_non_nullable
as int,prix: null == prix ? _self.prix : prix // ignore: cast_nullable_to_non_nullable
as double,isActif: null == isActif ? _self.isActif : isActif // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ServiceBeaute].
extension ServiceBeautePatterns on ServiceBeaute {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceBeaute value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceBeaute() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceBeaute value)  $default,){
final _that = this;
switch (_that) {
case _ServiceBeaute():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceBeaute value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceBeaute() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String prestataireId,  String nom,  String? description, @JsonKey(name: 'categorie_id')  String? categorieId,  int dureeMinutes, @DecimalConverter()  double prix,  bool isActif)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceBeaute() when $default != null:
return $default(_that.id,_that.prestataireId,_that.nom,_that.description,_that.categorieId,_that.dureeMinutes,_that.prix,_that.isActif);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String prestataireId,  String nom,  String? description, @JsonKey(name: 'categorie_id')  String? categorieId,  int dureeMinutes, @DecimalConverter()  double prix,  bool isActif)  $default,) {final _that = this;
switch (_that) {
case _ServiceBeaute():
return $default(_that.id,_that.prestataireId,_that.nom,_that.description,_that.categorieId,_that.dureeMinutes,_that.prix,_that.isActif);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String prestataireId,  String nom,  String? description, @JsonKey(name: 'categorie_id')  String? categorieId,  int dureeMinutes, @DecimalConverter()  double prix,  bool isActif)?  $default,) {final _that = this;
switch (_that) {
case _ServiceBeaute() when $default != null:
return $default(_that.id,_that.prestataireId,_that.nom,_that.description,_that.categorieId,_that.dureeMinutes,_that.prix,_that.isActif);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceBeaute implements ServiceBeaute {
  const _ServiceBeaute({required this.id, required this.prestataireId, required this.nom, this.description, @JsonKey(name: 'categorie_id') this.categorieId, this.dureeMinutes = 60, @DecimalConverter() this.prix = 0, this.isActif = true});
  factory _ServiceBeaute.fromJson(Map<String, dynamic> json) => _$ServiceBeauteFromJson(json);

@override final  String id;
@override final  String prestataireId;
@override final  String nom;
@override final  String? description;
@override@JsonKey(name: 'categorie_id') final  String? categorieId;
@override@JsonKey() final  int dureeMinutes;
@override@JsonKey()@DecimalConverter() final  double prix;
@override@JsonKey() final  bool isActif;

/// Create a copy of ServiceBeaute
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceBeauteCopyWith<_ServiceBeaute> get copyWith => __$ServiceBeauteCopyWithImpl<_ServiceBeaute>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceBeauteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceBeaute&&(identical(other.id, id) || other.id == id)&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.nom, nom) || other.nom == nom)&&(identical(other.description, description) || other.description == description)&&(identical(other.categorieId, categorieId) || other.categorieId == categorieId)&&(identical(other.dureeMinutes, dureeMinutes) || other.dureeMinutes == dureeMinutes)&&(identical(other.prix, prix) || other.prix == prix)&&(identical(other.isActif, isActif) || other.isActif == isActif));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,prestataireId,nom,description,categorieId,dureeMinutes,prix,isActif);

@override
String toString() {
  return 'ServiceBeaute(id: $id, prestataireId: $prestataireId, nom: $nom, description: $description, categorieId: $categorieId, dureeMinutes: $dureeMinutes, prix: $prix, isActif: $isActif)';
}


}

/// @nodoc
abstract mixin class _$ServiceBeauteCopyWith<$Res> implements $ServiceBeauteCopyWith<$Res> {
  factory _$ServiceBeauteCopyWith(_ServiceBeaute value, $Res Function(_ServiceBeaute) _then) = __$ServiceBeauteCopyWithImpl;
@override @useResult
$Res call({
 String id, String prestataireId, String nom, String? description,@JsonKey(name: 'categorie_id') String? categorieId, int dureeMinutes,@DecimalConverter() double prix, bool isActif
});




}
/// @nodoc
class __$ServiceBeauteCopyWithImpl<$Res>
    implements _$ServiceBeauteCopyWith<$Res> {
  __$ServiceBeauteCopyWithImpl(this._self, this._then);

  final _ServiceBeaute _self;
  final $Res Function(_ServiceBeaute) _then;

/// Create a copy of ServiceBeaute
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? prestataireId = null,Object? nom = null,Object? description = freezed,Object? categorieId = freezed,Object? dureeMinutes = null,Object? prix = null,Object? isActif = null,}) {
  return _then(_ServiceBeaute(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,nom: null == nom ? _self.nom : nom // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categorieId: freezed == categorieId ? _self.categorieId : categorieId // ignore: cast_nullable_to_non_nullable
as String?,dureeMinutes: null == dureeMinutes ? _self.dureeMinutes : dureeMinutes // ignore: cast_nullable_to_non_nullable
as int,prix: null == prix ? _self.prix : prix // ignore: cast_nullable_to_non_nullable
as double,isActif: null == isActif ? _self.isActif : isActif // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

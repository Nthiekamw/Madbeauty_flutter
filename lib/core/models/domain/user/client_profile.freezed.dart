// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientProfile {

 String get id; String get userId; String? get adresse; String? get ville;@JsonKey(name: 'code_postal') String? get codePostal; String? get pays;@JsonKey(name: 'voie_type') String? get voieType;@JsonKey(name: 'voie_nom') String? get voieNom;@JsonKey(name: 'numero_rue') String? get numeroRue; double? get latitude; double? get longitude;@IsoDateTimeConverter() DateTime get createdAt;
/// Create a copy of ClientProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientProfileCopyWith<ClientProfile> get copyWith => _$ClientProfileCopyWithImpl<ClientProfile>(this as ClientProfile, _$identity);

  /// Serializes this ClientProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.adresse, adresse) || other.adresse == adresse)&&(identical(other.ville, ville) || other.ville == ville)&&(identical(other.codePostal, codePostal) || other.codePostal == codePostal)&&(identical(other.pays, pays) || other.pays == pays)&&(identical(other.voieType, voieType) || other.voieType == voieType)&&(identical(other.voieNom, voieNom) || other.voieNom == voieNom)&&(identical(other.numeroRue, numeroRue) || other.numeroRue == numeroRue)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,adresse,ville,codePostal,pays,voieType,voieNom,numeroRue,latitude,longitude,createdAt);

@override
String toString() {
  return 'ClientProfile(id: $id, userId: $userId, adresse: $adresse, ville: $ville, codePostal: $codePostal, pays: $pays, voieType: $voieType, voieNom: $voieNom, numeroRue: $numeroRue, latitude: $latitude, longitude: $longitude, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ClientProfileCopyWith<$Res>  {
  factory $ClientProfileCopyWith(ClientProfile value, $Res Function(ClientProfile) _then) = _$ClientProfileCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String? adresse, String? ville,@JsonKey(name: 'code_postal') String? codePostal, String? pays,@JsonKey(name: 'voie_type') String? voieType,@JsonKey(name: 'voie_nom') String? voieNom,@JsonKey(name: 'numero_rue') String? numeroRue, double? latitude, double? longitude,@IsoDateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class _$ClientProfileCopyWithImpl<$Res>
    implements $ClientProfileCopyWith<$Res> {
  _$ClientProfileCopyWithImpl(this._self, this._then);

  final ClientProfile _self;
  final $Res Function(ClientProfile) _then;

/// Create a copy of ClientProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? adresse = freezed,Object? ville = freezed,Object? codePostal = freezed,Object? pays = freezed,Object? voieType = freezed,Object? voieNom = freezed,Object? numeroRue = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,adresse: freezed == adresse ? _self.adresse : adresse // ignore: cast_nullable_to_non_nullable
as String?,ville: freezed == ville ? _self.ville : ville // ignore: cast_nullable_to_non_nullable
as String?,codePostal: freezed == codePostal ? _self.codePostal : codePostal // ignore: cast_nullable_to_non_nullable
as String?,pays: freezed == pays ? _self.pays : pays // ignore: cast_nullable_to_non_nullable
as String?,voieType: freezed == voieType ? _self.voieType : voieType // ignore: cast_nullable_to_non_nullable
as String?,voieNom: freezed == voieNom ? _self.voieNom : voieNom // ignore: cast_nullable_to_non_nullable
as String?,numeroRue: freezed == numeroRue ? _self.numeroRue : numeroRue // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientProfile].
extension ClientProfilePatterns on ClientProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientProfile value)  $default,){
final _that = this;
switch (_that) {
case _ClientProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientProfile value)?  $default,){
final _that = this;
switch (_that) {
case _ClientProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String? adresse,  String? ville, @JsonKey(name: 'code_postal')  String? codePostal,  String? pays, @JsonKey(name: 'voie_type')  String? voieType, @JsonKey(name: 'voie_nom')  String? voieNom, @JsonKey(name: 'numero_rue')  String? numeroRue,  double? latitude,  double? longitude, @IsoDateTimeConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientProfile() when $default != null:
return $default(_that.id,_that.userId,_that.adresse,_that.ville,_that.codePostal,_that.pays,_that.voieType,_that.voieNom,_that.numeroRue,_that.latitude,_that.longitude,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String? adresse,  String? ville, @JsonKey(name: 'code_postal')  String? codePostal,  String? pays, @JsonKey(name: 'voie_type')  String? voieType, @JsonKey(name: 'voie_nom')  String? voieNom, @JsonKey(name: 'numero_rue')  String? numeroRue,  double? latitude,  double? longitude, @IsoDateTimeConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ClientProfile():
return $default(_that.id,_that.userId,_that.adresse,_that.ville,_that.codePostal,_that.pays,_that.voieType,_that.voieNom,_that.numeroRue,_that.latitude,_that.longitude,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String? adresse,  String? ville, @JsonKey(name: 'code_postal')  String? codePostal,  String? pays, @JsonKey(name: 'voie_type')  String? voieType, @JsonKey(name: 'voie_nom')  String? voieNom, @JsonKey(name: 'numero_rue')  String? numeroRue,  double? latitude,  double? longitude, @IsoDateTimeConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ClientProfile() when $default != null:
return $default(_that.id,_that.userId,_that.adresse,_that.ville,_that.codePostal,_that.pays,_that.voieType,_that.voieNom,_that.numeroRue,_that.latitude,_that.longitude,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClientProfile implements ClientProfile {
  const _ClientProfile({required this.id, required this.userId, this.adresse, this.ville, @JsonKey(name: 'code_postal') this.codePostal, this.pays, @JsonKey(name: 'voie_type') this.voieType, @JsonKey(name: 'voie_nom') this.voieNom, @JsonKey(name: 'numero_rue') this.numeroRue, this.latitude, this.longitude, @IsoDateTimeConverter() required this.createdAt});
  factory _ClientProfile.fromJson(Map<String, dynamic> json) => _$ClientProfileFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String? adresse;
@override final  String? ville;
@override@JsonKey(name: 'code_postal') final  String? codePostal;
@override final  String? pays;
@override@JsonKey(name: 'voie_type') final  String? voieType;
@override@JsonKey(name: 'voie_nom') final  String? voieNom;
@override@JsonKey(name: 'numero_rue') final  String? numeroRue;
@override final  double? latitude;
@override final  double? longitude;
@override@IsoDateTimeConverter() final  DateTime createdAt;

/// Create a copy of ClientProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientProfileCopyWith<_ClientProfile> get copyWith => __$ClientProfileCopyWithImpl<_ClientProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.adresse, adresse) || other.adresse == adresse)&&(identical(other.ville, ville) || other.ville == ville)&&(identical(other.codePostal, codePostal) || other.codePostal == codePostal)&&(identical(other.pays, pays) || other.pays == pays)&&(identical(other.voieType, voieType) || other.voieType == voieType)&&(identical(other.voieNom, voieNom) || other.voieNom == voieNom)&&(identical(other.numeroRue, numeroRue) || other.numeroRue == numeroRue)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,adresse,ville,codePostal,pays,voieType,voieNom,numeroRue,latitude,longitude,createdAt);

@override
String toString() {
  return 'ClientProfile(id: $id, userId: $userId, adresse: $adresse, ville: $ville, codePostal: $codePostal, pays: $pays, voieType: $voieType, voieNom: $voieNom, numeroRue: $numeroRue, latitude: $latitude, longitude: $longitude, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ClientProfileCopyWith<$Res> implements $ClientProfileCopyWith<$Res> {
  factory _$ClientProfileCopyWith(_ClientProfile value, $Res Function(_ClientProfile) _then) = __$ClientProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String? adresse, String? ville,@JsonKey(name: 'code_postal') String? codePostal, String? pays,@JsonKey(name: 'voie_type') String? voieType,@JsonKey(name: 'voie_nom') String? voieNom,@JsonKey(name: 'numero_rue') String? numeroRue, double? latitude, double? longitude,@IsoDateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class __$ClientProfileCopyWithImpl<$Res>
    implements _$ClientProfileCopyWith<$Res> {
  __$ClientProfileCopyWithImpl(this._self, this._then);

  final _ClientProfile _self;
  final $Res Function(_ClientProfile) _then;

/// Create a copy of ClientProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? adresse = freezed,Object? ville = freezed,Object? codePostal = freezed,Object? pays = freezed,Object? voieType = freezed,Object? voieNom = freezed,Object? numeroRue = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? createdAt = null,}) {
  return _then(_ClientProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,adresse: freezed == adresse ? _self.adresse : adresse // ignore: cast_nullable_to_non_nullable
as String?,ville: freezed == ville ? _self.ville : ville // ignore: cast_nullable_to_non_nullable
as String?,codePostal: freezed == codePostal ? _self.codePostal : codePostal // ignore: cast_nullable_to_non_nullable
as String?,pays: freezed == pays ? _self.pays : pays // ignore: cast_nullable_to_non_nullable
as String?,voieType: freezed == voieType ? _self.voieType : voieType // ignore: cast_nullable_to_non_nullable
as String?,voieNom: freezed == voieNom ? _self.voieNom : voieNom // ignore: cast_nullable_to_non_nullable
as String?,numeroRue: freezed == numeroRue ? _self.numeroRue : numeroRue // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

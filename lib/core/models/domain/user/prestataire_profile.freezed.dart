// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prestataire_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrestataireProfile {

 String get id; String get userId; String? get nomSalon; String? get bio; String? get ville; double? get latitude; double? get longitude; double? get noteMoyenne; bool get isVerified;@IsoDateTimeConverter() DateTime get createdAt;
/// Create a copy of PrestataireProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrestataireProfileCopyWith<PrestataireProfile> get copyWith => _$PrestataireProfileCopyWithImpl<PrestataireProfile>(this as PrestataireProfile, _$identity);

  /// Serializes this PrestataireProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrestataireProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.nomSalon, nomSalon) || other.nomSalon == nomSalon)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.ville, ville) || other.ville == ville)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.noteMoyenne, noteMoyenne) || other.noteMoyenne == noteMoyenne)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,nomSalon,bio,ville,latitude,longitude,noteMoyenne,isVerified,createdAt);

@override
String toString() {
  return 'PrestataireProfile(id: $id, userId: $userId, nomSalon: $nomSalon, bio: $bio, ville: $ville, latitude: $latitude, longitude: $longitude, noteMoyenne: $noteMoyenne, isVerified: $isVerified, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PrestataireProfileCopyWith<$Res>  {
  factory $PrestataireProfileCopyWith(PrestataireProfile value, $Res Function(PrestataireProfile) _then) = _$PrestataireProfileCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String? nomSalon, String? bio, String? ville, double? latitude, double? longitude, double? noteMoyenne, bool isVerified,@IsoDateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class _$PrestataireProfileCopyWithImpl<$Res>
    implements $PrestataireProfileCopyWith<$Res> {
  _$PrestataireProfileCopyWithImpl(this._self, this._then);

  final PrestataireProfile _self;
  final $Res Function(PrestataireProfile) _then;

/// Create a copy of PrestataireProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? nomSalon = freezed,Object? bio = freezed,Object? ville = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? noteMoyenne = freezed,Object? isVerified = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,nomSalon: freezed == nomSalon ? _self.nomSalon : nomSalon // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,ville: freezed == ville ? _self.ville : ville // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,noteMoyenne: freezed == noteMoyenne ? _self.noteMoyenne : noteMoyenne // ignore: cast_nullable_to_non_nullable
as double?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PrestataireProfile].
extension PrestataireProfilePatterns on PrestataireProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrestataireProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrestataireProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrestataireProfile value)  $default,){
final _that = this;
switch (_that) {
case _PrestataireProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrestataireProfile value)?  $default,){
final _that = this;
switch (_that) {
case _PrestataireProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String? nomSalon,  String? bio,  String? ville,  double? latitude,  double? longitude,  double? noteMoyenne,  bool isVerified, @IsoDateTimeConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrestataireProfile() when $default != null:
return $default(_that.id,_that.userId,_that.nomSalon,_that.bio,_that.ville,_that.latitude,_that.longitude,_that.noteMoyenne,_that.isVerified,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String? nomSalon,  String? bio,  String? ville,  double? latitude,  double? longitude,  double? noteMoyenne,  bool isVerified, @IsoDateTimeConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PrestataireProfile():
return $default(_that.id,_that.userId,_that.nomSalon,_that.bio,_that.ville,_that.latitude,_that.longitude,_that.noteMoyenne,_that.isVerified,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String? nomSalon,  String? bio,  String? ville,  double? latitude,  double? longitude,  double? noteMoyenne,  bool isVerified, @IsoDateTimeConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PrestataireProfile() when $default != null:
return $default(_that.id,_that.userId,_that.nomSalon,_that.bio,_that.ville,_that.latitude,_that.longitude,_that.noteMoyenne,_that.isVerified,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrestataireProfile implements PrestataireProfile {
  const _PrestataireProfile({required this.id, required this.userId, this.nomSalon, this.bio, this.ville, this.latitude, this.longitude, this.noteMoyenne, this.isVerified = false, @IsoDateTimeConverter() required this.createdAt});
  factory _PrestataireProfile.fromJson(Map<String, dynamic> json) => _$PrestataireProfileFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String? nomSalon;
@override final  String? bio;
@override final  String? ville;
@override final  double? latitude;
@override final  double? longitude;
@override final  double? noteMoyenne;
@override@JsonKey() final  bool isVerified;
@override@IsoDateTimeConverter() final  DateTime createdAt;

/// Create a copy of PrestataireProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrestataireProfileCopyWith<_PrestataireProfile> get copyWith => __$PrestataireProfileCopyWithImpl<_PrestataireProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrestataireProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrestataireProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.nomSalon, nomSalon) || other.nomSalon == nomSalon)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.ville, ville) || other.ville == ville)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.noteMoyenne, noteMoyenne) || other.noteMoyenne == noteMoyenne)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,nomSalon,bio,ville,latitude,longitude,noteMoyenne,isVerified,createdAt);

@override
String toString() {
  return 'PrestataireProfile(id: $id, userId: $userId, nomSalon: $nomSalon, bio: $bio, ville: $ville, latitude: $latitude, longitude: $longitude, noteMoyenne: $noteMoyenne, isVerified: $isVerified, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PrestataireProfileCopyWith<$Res> implements $PrestataireProfileCopyWith<$Res> {
  factory _$PrestataireProfileCopyWith(_PrestataireProfile value, $Res Function(_PrestataireProfile) _then) = __$PrestataireProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String? nomSalon, String? bio, String? ville, double? latitude, double? longitude, double? noteMoyenne, bool isVerified,@IsoDateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class __$PrestataireProfileCopyWithImpl<$Res>
    implements _$PrestataireProfileCopyWith<$Res> {
  __$PrestataireProfileCopyWithImpl(this._self, this._then);

  final _PrestataireProfile _self;
  final $Res Function(_PrestataireProfile) _then;

/// Create a copy of PrestataireProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? nomSalon = freezed,Object? bio = freezed,Object? ville = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? noteMoyenne = freezed,Object? isVerified = null,Object? createdAt = null,}) {
  return _then(_PrestataireProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,nomSalon: freezed == nomSalon ? _self.nomSalon : nomSalon // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,ville: freezed == ville ? _self.ville : ville // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,noteMoyenne: freezed == noteMoyenne ? _self.noteMoyenne : noteMoyenne // ignore: cast_nullable_to_non_nullable
as double?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

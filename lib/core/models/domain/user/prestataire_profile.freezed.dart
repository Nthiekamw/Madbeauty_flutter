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

 String get id; String get userId; String? get nomSalon; String? get bio; String? get ville; String? get adresse;@JsonKey(name: 'code_postal') String? get codePostal;/// Code ISO 3166-1 alpha-2 (ex. FR, BE).
 String? get pays;@JsonKey(name: 'nom_affiche') String? get nomAffiche;@JsonKey(name: 'lieu_travail')@LieuTravailConverter() LieuTravail? get lieuTravail;@JsonKey(name: 'annees_experience') String? get anneesExperience;@JsonKey(name: 'experience_professionnelle') String? get experienceProfessionnelle; String? get description;@JsonKey(name: 'confort_client') List<String> get confortClient;@JsonKey(name: 'conditions_service', fromJson: _conditionsServiceFromJson) List<String> get conditionsService; double? get latitude; double? get longitude; double? get noteMoyenne; bool get isVerified;@IsoDateTimeConverter() DateTime get createdAt;
/// Create a copy of PrestataireProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrestataireProfileCopyWith<PrestataireProfile> get copyWith => _$PrestataireProfileCopyWithImpl<PrestataireProfile>(this as PrestataireProfile, _$identity);

  /// Serializes this PrestataireProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrestataireProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.nomSalon, nomSalon) || other.nomSalon == nomSalon)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.ville, ville) || other.ville == ville)&&(identical(other.adresse, adresse) || other.adresse == adresse)&&(identical(other.codePostal, codePostal) || other.codePostal == codePostal)&&(identical(other.pays, pays) || other.pays == pays)&&(identical(other.nomAffiche, nomAffiche) || other.nomAffiche == nomAffiche)&&(identical(other.lieuTravail, lieuTravail) || other.lieuTravail == lieuTravail)&&(identical(other.anneesExperience, anneesExperience) || other.anneesExperience == anneesExperience)&&(identical(other.experienceProfessionnelle, experienceProfessionnelle) || other.experienceProfessionnelle == experienceProfessionnelle)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.confortClient, confortClient)&&const DeepCollectionEquality().equals(other.conditionsService, conditionsService)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.noteMoyenne, noteMoyenne) || other.noteMoyenne == noteMoyenne)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,nomSalon,bio,ville,adresse,codePostal,pays,nomAffiche,lieuTravail,anneesExperience,experienceProfessionnelle,description,const DeepCollectionEquality().hash(confortClient),const DeepCollectionEquality().hash(conditionsService),latitude,longitude,noteMoyenne,isVerified,createdAt]);

@override
String toString() {
  return 'PrestataireProfile(id: $id, userId: $userId, nomSalon: $nomSalon, bio: $bio, ville: $ville, adresse: $adresse, codePostal: $codePostal, pays: $pays, nomAffiche: $nomAffiche, lieuTravail: $lieuTravail, anneesExperience: $anneesExperience, experienceProfessionnelle: $experienceProfessionnelle, description: $description, confortClient: $confortClient, conditionsService: $conditionsService, latitude: $latitude, longitude: $longitude, noteMoyenne: $noteMoyenne, isVerified: $isVerified, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PrestataireProfileCopyWith<$Res>  {
  factory $PrestataireProfileCopyWith(PrestataireProfile value, $Res Function(PrestataireProfile) _then) = _$PrestataireProfileCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String? nomSalon, String? bio, String? ville, String? adresse,@JsonKey(name: 'code_postal') String? codePostal, String? pays,@JsonKey(name: 'nom_affiche') String? nomAffiche,@JsonKey(name: 'lieu_travail')@LieuTravailConverter() LieuTravail? lieuTravail,@JsonKey(name: 'annees_experience') String? anneesExperience,@JsonKey(name: 'experience_professionnelle') String? experienceProfessionnelle, String? description,@JsonKey(name: 'confort_client') List<String> confortClient,@JsonKey(name: 'conditions_service', fromJson: _conditionsServiceFromJson) List<String> conditionsService, double? latitude, double? longitude, double? noteMoyenne, bool isVerified,@IsoDateTimeConverter() DateTime createdAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? nomSalon = freezed,Object? bio = freezed,Object? ville = freezed,Object? adresse = freezed,Object? codePostal = freezed,Object? pays = freezed,Object? nomAffiche = freezed,Object? lieuTravail = freezed,Object? anneesExperience = freezed,Object? experienceProfessionnelle = freezed,Object? description = freezed,Object? confortClient = null,Object? conditionsService = null,Object? latitude = freezed,Object? longitude = freezed,Object? noteMoyenne = freezed,Object? isVerified = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,nomSalon: freezed == nomSalon ? _self.nomSalon : nomSalon // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,ville: freezed == ville ? _self.ville : ville // ignore: cast_nullable_to_non_nullable
as String?,adresse: freezed == adresse ? _self.adresse : adresse // ignore: cast_nullable_to_non_nullable
as String?,codePostal: freezed == codePostal ? _self.codePostal : codePostal // ignore: cast_nullable_to_non_nullable
as String?,pays: freezed == pays ? _self.pays : pays // ignore: cast_nullable_to_non_nullable
as String?,nomAffiche: freezed == nomAffiche ? _self.nomAffiche : nomAffiche // ignore: cast_nullable_to_non_nullable
as String?,lieuTravail: freezed == lieuTravail ? _self.lieuTravail : lieuTravail // ignore: cast_nullable_to_non_nullable
as LieuTravail?,anneesExperience: freezed == anneesExperience ? _self.anneesExperience : anneesExperience // ignore: cast_nullable_to_non_nullable
as String?,experienceProfessionnelle: freezed == experienceProfessionnelle ? _self.experienceProfessionnelle : experienceProfessionnelle // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,confortClient: null == confortClient ? _self.confortClient : confortClient // ignore: cast_nullable_to_non_nullable
as List<String>,conditionsService: null == conditionsService ? _self.conditionsService : conditionsService // ignore: cast_nullable_to_non_nullable
as List<String>,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String? nomSalon,  String? bio,  String? ville,  String? adresse, @JsonKey(name: 'code_postal')  String? codePostal,  String? pays, @JsonKey(name: 'nom_affiche')  String? nomAffiche, @JsonKey(name: 'lieu_travail')@LieuTravailConverter()  LieuTravail? lieuTravail, @JsonKey(name: 'annees_experience')  String? anneesExperience, @JsonKey(name: 'experience_professionnelle')  String? experienceProfessionnelle,  String? description, @JsonKey(name: 'confort_client')  List<String> confortClient, @JsonKey(name: 'conditions_service', fromJson: _conditionsServiceFromJson)  List<String> conditionsService,  double? latitude,  double? longitude,  double? noteMoyenne,  bool isVerified, @IsoDateTimeConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrestataireProfile() when $default != null:
return $default(_that.id,_that.userId,_that.nomSalon,_that.bio,_that.ville,_that.adresse,_that.codePostal,_that.pays,_that.nomAffiche,_that.lieuTravail,_that.anneesExperience,_that.experienceProfessionnelle,_that.description,_that.confortClient,_that.conditionsService,_that.latitude,_that.longitude,_that.noteMoyenne,_that.isVerified,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String? nomSalon,  String? bio,  String? ville,  String? adresse, @JsonKey(name: 'code_postal')  String? codePostal,  String? pays, @JsonKey(name: 'nom_affiche')  String? nomAffiche, @JsonKey(name: 'lieu_travail')@LieuTravailConverter()  LieuTravail? lieuTravail, @JsonKey(name: 'annees_experience')  String? anneesExperience, @JsonKey(name: 'experience_professionnelle')  String? experienceProfessionnelle,  String? description, @JsonKey(name: 'confort_client')  List<String> confortClient, @JsonKey(name: 'conditions_service', fromJson: _conditionsServiceFromJson)  List<String> conditionsService,  double? latitude,  double? longitude,  double? noteMoyenne,  bool isVerified, @IsoDateTimeConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PrestataireProfile():
return $default(_that.id,_that.userId,_that.nomSalon,_that.bio,_that.ville,_that.adresse,_that.codePostal,_that.pays,_that.nomAffiche,_that.lieuTravail,_that.anneesExperience,_that.experienceProfessionnelle,_that.description,_that.confortClient,_that.conditionsService,_that.latitude,_that.longitude,_that.noteMoyenne,_that.isVerified,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String? nomSalon,  String? bio,  String? ville,  String? adresse, @JsonKey(name: 'code_postal')  String? codePostal,  String? pays, @JsonKey(name: 'nom_affiche')  String? nomAffiche, @JsonKey(name: 'lieu_travail')@LieuTravailConverter()  LieuTravail? lieuTravail, @JsonKey(name: 'annees_experience')  String? anneesExperience, @JsonKey(name: 'experience_professionnelle')  String? experienceProfessionnelle,  String? description, @JsonKey(name: 'confort_client')  List<String> confortClient, @JsonKey(name: 'conditions_service', fromJson: _conditionsServiceFromJson)  List<String> conditionsService,  double? latitude,  double? longitude,  double? noteMoyenne,  bool isVerified, @IsoDateTimeConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PrestataireProfile() when $default != null:
return $default(_that.id,_that.userId,_that.nomSalon,_that.bio,_that.ville,_that.adresse,_that.codePostal,_that.pays,_that.nomAffiche,_that.lieuTravail,_that.anneesExperience,_that.experienceProfessionnelle,_that.description,_that.confortClient,_that.conditionsService,_that.latitude,_that.longitude,_that.noteMoyenne,_that.isVerified,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrestataireProfile implements PrestataireProfile {
  const _PrestataireProfile({required this.id, required this.userId, this.nomSalon, this.bio, this.ville, this.adresse, @JsonKey(name: 'code_postal') this.codePostal, this.pays, @JsonKey(name: 'nom_affiche') this.nomAffiche, @JsonKey(name: 'lieu_travail')@LieuTravailConverter() this.lieuTravail, @JsonKey(name: 'annees_experience') this.anneesExperience, @JsonKey(name: 'experience_professionnelle') this.experienceProfessionnelle, this.description, @JsonKey(name: 'confort_client') final  List<String> confortClient = const [], @JsonKey(name: 'conditions_service', fromJson: _conditionsServiceFromJson) final  List<String> conditionsService = const [], this.latitude, this.longitude, this.noteMoyenne, this.isVerified = false, @IsoDateTimeConverter() required this.createdAt}): _confortClient = confortClient,_conditionsService = conditionsService;
  factory _PrestataireProfile.fromJson(Map<String, dynamic> json) => _$PrestataireProfileFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String? nomSalon;
@override final  String? bio;
@override final  String? ville;
@override final  String? adresse;
@override@JsonKey(name: 'code_postal') final  String? codePostal;
/// Code ISO 3166-1 alpha-2 (ex. FR, BE).
@override final  String? pays;
@override@JsonKey(name: 'nom_affiche') final  String? nomAffiche;
@override@JsonKey(name: 'lieu_travail')@LieuTravailConverter() final  LieuTravail? lieuTravail;
@override@JsonKey(name: 'annees_experience') final  String? anneesExperience;
@override@JsonKey(name: 'experience_professionnelle') final  String? experienceProfessionnelle;
@override final  String? description;
 final  List<String> _confortClient;
@override@JsonKey(name: 'confort_client') List<String> get confortClient {
  if (_confortClient is EqualUnmodifiableListView) return _confortClient;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_confortClient);
}

 final  List<String> _conditionsService;
@override@JsonKey(name: 'conditions_service', fromJson: _conditionsServiceFromJson) List<String> get conditionsService {
  if (_conditionsService is EqualUnmodifiableListView) return _conditionsService;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conditionsService);
}

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrestataireProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.nomSalon, nomSalon) || other.nomSalon == nomSalon)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.ville, ville) || other.ville == ville)&&(identical(other.adresse, adresse) || other.adresse == adresse)&&(identical(other.codePostal, codePostal) || other.codePostal == codePostal)&&(identical(other.pays, pays) || other.pays == pays)&&(identical(other.nomAffiche, nomAffiche) || other.nomAffiche == nomAffiche)&&(identical(other.lieuTravail, lieuTravail) || other.lieuTravail == lieuTravail)&&(identical(other.anneesExperience, anneesExperience) || other.anneesExperience == anneesExperience)&&(identical(other.experienceProfessionnelle, experienceProfessionnelle) || other.experienceProfessionnelle == experienceProfessionnelle)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._confortClient, _confortClient)&&const DeepCollectionEquality().equals(other._conditionsService, _conditionsService)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.noteMoyenne, noteMoyenne) || other.noteMoyenne == noteMoyenne)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,nomSalon,bio,ville,adresse,codePostal,pays,nomAffiche,lieuTravail,anneesExperience,experienceProfessionnelle,description,const DeepCollectionEquality().hash(_confortClient),const DeepCollectionEquality().hash(_conditionsService),latitude,longitude,noteMoyenne,isVerified,createdAt]);

@override
String toString() {
  return 'PrestataireProfile(id: $id, userId: $userId, nomSalon: $nomSalon, bio: $bio, ville: $ville, adresse: $adresse, codePostal: $codePostal, pays: $pays, nomAffiche: $nomAffiche, lieuTravail: $lieuTravail, anneesExperience: $anneesExperience, experienceProfessionnelle: $experienceProfessionnelle, description: $description, confortClient: $confortClient, conditionsService: $conditionsService, latitude: $latitude, longitude: $longitude, noteMoyenne: $noteMoyenne, isVerified: $isVerified, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PrestataireProfileCopyWith<$Res> implements $PrestataireProfileCopyWith<$Res> {
  factory _$PrestataireProfileCopyWith(_PrestataireProfile value, $Res Function(_PrestataireProfile) _then) = __$PrestataireProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String? nomSalon, String? bio, String? ville, String? adresse,@JsonKey(name: 'code_postal') String? codePostal, String? pays,@JsonKey(name: 'nom_affiche') String? nomAffiche,@JsonKey(name: 'lieu_travail')@LieuTravailConverter() LieuTravail? lieuTravail,@JsonKey(name: 'annees_experience') String? anneesExperience,@JsonKey(name: 'experience_professionnelle') String? experienceProfessionnelle, String? description,@JsonKey(name: 'confort_client') List<String> confortClient,@JsonKey(name: 'conditions_service', fromJson: _conditionsServiceFromJson) List<String> conditionsService, double? latitude, double? longitude, double? noteMoyenne, bool isVerified,@IsoDateTimeConverter() DateTime createdAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? nomSalon = freezed,Object? bio = freezed,Object? ville = freezed,Object? adresse = freezed,Object? codePostal = freezed,Object? pays = freezed,Object? nomAffiche = freezed,Object? lieuTravail = freezed,Object? anneesExperience = freezed,Object? experienceProfessionnelle = freezed,Object? description = freezed,Object? confortClient = null,Object? conditionsService = null,Object? latitude = freezed,Object? longitude = freezed,Object? noteMoyenne = freezed,Object? isVerified = null,Object? createdAt = null,}) {
  return _then(_PrestataireProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,nomSalon: freezed == nomSalon ? _self.nomSalon : nomSalon // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,ville: freezed == ville ? _self.ville : ville // ignore: cast_nullable_to_non_nullable
as String?,adresse: freezed == adresse ? _self.adresse : adresse // ignore: cast_nullable_to_non_nullable
as String?,codePostal: freezed == codePostal ? _self.codePostal : codePostal // ignore: cast_nullable_to_non_nullable
as String?,pays: freezed == pays ? _self.pays : pays // ignore: cast_nullable_to_non_nullable
as String?,nomAffiche: freezed == nomAffiche ? _self.nomAffiche : nomAffiche // ignore: cast_nullable_to_non_nullable
as String?,lieuTravail: freezed == lieuTravail ? _self.lieuTravail : lieuTravail // ignore: cast_nullable_to_non_nullable
as LieuTravail?,anneesExperience: freezed == anneesExperience ? _self.anneesExperience : anneesExperience // ignore: cast_nullable_to_non_nullable
as String?,experienceProfessionnelle: freezed == experienceProfessionnelle ? _self.experienceProfessionnelle : experienceProfessionnelle // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,confortClient: null == confortClient ? _self._confortClient : confortClient // ignore: cast_nullable_to_non_nullable
as List<String>,conditionsService: null == conditionsService ? _self._conditionsService : conditionsService // ignore: cast_nullable_to_non_nullable
as List<String>,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,noteMoyenne: freezed == noteMoyenne ? _self.noteMoyenne : noteMoyenne // ignore: cast_nullable_to_non_nullable
as double?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

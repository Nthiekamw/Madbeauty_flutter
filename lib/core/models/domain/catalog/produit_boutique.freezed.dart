// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'produit_boutique.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProduitBoutique {

 String get id; String get prestataireId; String get nom; String? get description; String? get conditionnement; ProduitBoutiqueCategorie get categorie;@DecimalConverter() double get prix; String? get imageUrl; bool get isActif; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of ProduitBoutique
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProduitBoutiqueCopyWith<ProduitBoutique> get copyWith => _$ProduitBoutiqueCopyWithImpl<ProduitBoutique>(this as ProduitBoutique, _$identity);

  /// Serializes this ProduitBoutique to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProduitBoutique&&(identical(other.id, id) || other.id == id)&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.nom, nom) || other.nom == nom)&&(identical(other.description, description) || other.description == description)&&(identical(other.conditionnement, conditionnement) || other.conditionnement == conditionnement)&&(identical(other.categorie, categorie) || other.categorie == categorie)&&(identical(other.prix, prix) || other.prix == prix)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isActif, isActif) || other.isActif == isActif)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,prestataireId,nom,description,conditionnement,categorie,prix,imageUrl,isActif,createdAt,updatedAt);

@override
String toString() {
  return 'ProduitBoutique(id: $id, prestataireId: $prestataireId, nom: $nom, description: $description, conditionnement: $conditionnement, categorie: $categorie, prix: $prix, imageUrl: $imageUrl, isActif: $isActif, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProduitBoutiqueCopyWith<$Res>  {
  factory $ProduitBoutiqueCopyWith(ProduitBoutique value, $Res Function(ProduitBoutique) _then) = _$ProduitBoutiqueCopyWithImpl;
@useResult
$Res call({
 String id, String prestataireId, String nom, String? description, String? conditionnement, ProduitBoutiqueCategorie categorie,@DecimalConverter() double prix, String? imageUrl, bool isActif, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ProduitBoutiqueCopyWithImpl<$Res>
    implements $ProduitBoutiqueCopyWith<$Res> {
  _$ProduitBoutiqueCopyWithImpl(this._self, this._then);

  final ProduitBoutique _self;
  final $Res Function(ProduitBoutique) _then;

/// Create a copy of ProduitBoutique
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? prestataireId = null,Object? nom = null,Object? description = freezed,Object? conditionnement = freezed,Object? categorie = null,Object? prix = null,Object? imageUrl = freezed,Object? isActif = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,nom: null == nom ? _self.nom : nom // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,conditionnement: freezed == conditionnement ? _self.conditionnement : conditionnement // ignore: cast_nullable_to_non_nullable
as String?,categorie: null == categorie ? _self.categorie : categorie // ignore: cast_nullable_to_non_nullable
as ProduitBoutiqueCategorie,prix: null == prix ? _self.prix : prix // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isActif: null == isActif ? _self.isActif : isActif // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProduitBoutique].
extension ProduitBoutiquePatterns on ProduitBoutique {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProduitBoutique value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProduitBoutique() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProduitBoutique value)  $default,){
final _that = this;
switch (_that) {
case _ProduitBoutique():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProduitBoutique value)?  $default,){
final _that = this;
switch (_that) {
case _ProduitBoutique() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String prestataireId,  String nom,  String? description,  String? conditionnement,  ProduitBoutiqueCategorie categorie, @DecimalConverter()  double prix,  String? imageUrl,  bool isActif,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProduitBoutique() when $default != null:
return $default(_that.id,_that.prestataireId,_that.nom,_that.description,_that.conditionnement,_that.categorie,_that.prix,_that.imageUrl,_that.isActif,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String prestataireId,  String nom,  String? description,  String? conditionnement,  ProduitBoutiqueCategorie categorie, @DecimalConverter()  double prix,  String? imageUrl,  bool isActif,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ProduitBoutique():
return $default(_that.id,_that.prestataireId,_that.nom,_that.description,_that.conditionnement,_that.categorie,_that.prix,_that.imageUrl,_that.isActif,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String prestataireId,  String nom,  String? description,  String? conditionnement,  ProduitBoutiqueCategorie categorie, @DecimalConverter()  double prix,  String? imageUrl,  bool isActif,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProduitBoutique() when $default != null:
return $default(_that.id,_that.prestataireId,_that.nom,_that.description,_that.conditionnement,_that.categorie,_that.prix,_that.imageUrl,_that.isActif,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProduitBoutique implements ProduitBoutique {
  const _ProduitBoutique({required this.id, required this.prestataireId, required this.nom, this.description, this.conditionnement, this.categorie = ProduitBoutiqueCategorie.autre, @DecimalConverter() this.prix = 0, this.imageUrl, this.isActif = true, this.createdAt, this.updatedAt});
  factory _ProduitBoutique.fromJson(Map<String, dynamic> json) => _$ProduitBoutiqueFromJson(json);

@override final  String id;
@override final  String prestataireId;
@override final  String nom;
@override final  String? description;
@override final  String? conditionnement;
@override@JsonKey() final  ProduitBoutiqueCategorie categorie;
@override@JsonKey()@DecimalConverter() final  double prix;
@override final  String? imageUrl;
@override@JsonKey() final  bool isActif;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of ProduitBoutique
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProduitBoutiqueCopyWith<_ProduitBoutique> get copyWith => __$ProduitBoutiqueCopyWithImpl<_ProduitBoutique>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProduitBoutiqueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProduitBoutique&&(identical(other.id, id) || other.id == id)&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.nom, nom) || other.nom == nom)&&(identical(other.description, description) || other.description == description)&&(identical(other.conditionnement, conditionnement) || other.conditionnement == conditionnement)&&(identical(other.categorie, categorie) || other.categorie == categorie)&&(identical(other.prix, prix) || other.prix == prix)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isActif, isActif) || other.isActif == isActif)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,prestataireId,nom,description,conditionnement,categorie,prix,imageUrl,isActif,createdAt,updatedAt);

@override
String toString() {
  return 'ProduitBoutique(id: $id, prestataireId: $prestataireId, nom: $nom, description: $description, conditionnement: $conditionnement, categorie: $categorie, prix: $prix, imageUrl: $imageUrl, isActif: $isActif, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProduitBoutiqueCopyWith<$Res> implements $ProduitBoutiqueCopyWith<$Res> {
  factory _$ProduitBoutiqueCopyWith(_ProduitBoutique value, $Res Function(_ProduitBoutique) _then) = __$ProduitBoutiqueCopyWithImpl;
@override @useResult
$Res call({
 String id, String prestataireId, String nom, String? description, String? conditionnement, ProduitBoutiqueCategorie categorie,@DecimalConverter() double prix, String? imageUrl, bool isActif, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ProduitBoutiqueCopyWithImpl<$Res>
    implements _$ProduitBoutiqueCopyWith<$Res> {
  __$ProduitBoutiqueCopyWithImpl(this._self, this._then);

  final _ProduitBoutique _self;
  final $Res Function(_ProduitBoutique) _then;

/// Create a copy of ProduitBoutique
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? prestataireId = null,Object? nom = null,Object? description = freezed,Object? conditionnement = freezed,Object? categorie = null,Object? prix = null,Object? imageUrl = freezed,Object? isActif = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ProduitBoutique(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,nom: null == nom ? _self.nom : nom // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,conditionnement: freezed == conditionnement ? _self.conditionnement : conditionnement // ignore: cast_nullable_to_non_nullable
as String?,categorie: null == categorie ? _self.categorie : categorie // ignore: cast_nullable_to_non_nullable
as ProduitBoutiqueCategorie,prix: null == prix ? _self.prix : prix // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isActif: null == isActif ? _self.isActif : isActif // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

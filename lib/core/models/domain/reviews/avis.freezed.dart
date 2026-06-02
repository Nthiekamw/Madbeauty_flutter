// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'avis.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Avis {

 String get id; String get clientId; String get prestataireId; String get reservationId; int get note; String? get commentaire;@JsonKey(name: 'photo_urls') List<String> get photoUrls;@IsoDateTimeConverter() DateTime get createdAt;
/// Create a copy of Avis
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvisCopyWith<Avis> get copyWith => _$AvisCopyWithImpl<Avis>(this as Avis, _$identity);

  /// Serializes this Avis to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Avis&&(identical(other.id, id) || other.id == id)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.reservationId, reservationId) || other.reservationId == reservationId)&&(identical(other.note, note) || other.note == note)&&(identical(other.commentaire, commentaire) || other.commentaire == commentaire)&&const DeepCollectionEquality().equals(other.photoUrls, photoUrls)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,clientId,prestataireId,reservationId,note,commentaire,const DeepCollectionEquality().hash(photoUrls),createdAt);

@override
String toString() {
  return 'Avis(id: $id, clientId: $clientId, prestataireId: $prestataireId, reservationId: $reservationId, note: $note, commentaire: $commentaire, photoUrls: $photoUrls, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AvisCopyWith<$Res>  {
  factory $AvisCopyWith(Avis value, $Res Function(Avis) _then) = _$AvisCopyWithImpl;
@useResult
$Res call({
 String id, String clientId, String prestataireId, String reservationId, int note, String? commentaire,@JsonKey(name: 'photo_urls') List<String> photoUrls,@IsoDateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class _$AvisCopyWithImpl<$Res>
    implements $AvisCopyWith<$Res> {
  _$AvisCopyWithImpl(this._self, this._then);

  final Avis _self;
  final $Res Function(Avis) _then;

/// Create a copy of Avis
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? clientId = null,Object? prestataireId = null,Object? reservationId = null,Object? note = null,Object? commentaire = freezed,Object? photoUrls = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,reservationId: null == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as int,commentaire: freezed == commentaire ? _self.commentaire : commentaire // ignore: cast_nullable_to_non_nullable
as String?,photoUrls: null == photoUrls ? _self.photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Avis].
extension AvisPatterns on Avis {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Avis value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Avis() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Avis value)  $default,){
final _that = this;
switch (_that) {
case _Avis():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Avis value)?  $default,){
final _that = this;
switch (_that) {
case _Avis() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String clientId,  String prestataireId,  String reservationId,  int note,  String? commentaire, @JsonKey(name: 'photo_urls')  List<String> photoUrls, @IsoDateTimeConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Avis() when $default != null:
return $default(_that.id,_that.clientId,_that.prestataireId,_that.reservationId,_that.note,_that.commentaire,_that.photoUrls,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String clientId,  String prestataireId,  String reservationId,  int note,  String? commentaire, @JsonKey(name: 'photo_urls')  List<String> photoUrls, @IsoDateTimeConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Avis():
return $default(_that.id,_that.clientId,_that.prestataireId,_that.reservationId,_that.note,_that.commentaire,_that.photoUrls,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String clientId,  String prestataireId,  String reservationId,  int note,  String? commentaire, @JsonKey(name: 'photo_urls')  List<String> photoUrls, @IsoDateTimeConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Avis() when $default != null:
return $default(_that.id,_that.clientId,_that.prestataireId,_that.reservationId,_that.note,_that.commentaire,_that.photoUrls,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Avis implements Avis {
  const _Avis({required this.id, required this.clientId, required this.prestataireId, required this.reservationId, required this.note, this.commentaire, @JsonKey(name: 'photo_urls') final  List<String> photoUrls = const [], @IsoDateTimeConverter() required this.createdAt}): _photoUrls = photoUrls;
  factory _Avis.fromJson(Map<String, dynamic> json) => _$AvisFromJson(json);

@override final  String id;
@override final  String clientId;
@override final  String prestataireId;
@override final  String reservationId;
@override final  int note;
@override final  String? commentaire;
 final  List<String> _photoUrls;
@override@JsonKey(name: 'photo_urls') List<String> get photoUrls {
  if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoUrls);
}

@override@IsoDateTimeConverter() final  DateTime createdAt;

/// Create a copy of Avis
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvisCopyWith<_Avis> get copyWith => __$AvisCopyWithImpl<_Avis>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvisToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Avis&&(identical(other.id, id) || other.id == id)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.reservationId, reservationId) || other.reservationId == reservationId)&&(identical(other.note, note) || other.note == note)&&(identical(other.commentaire, commentaire) || other.commentaire == commentaire)&&const DeepCollectionEquality().equals(other._photoUrls, _photoUrls)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,clientId,prestataireId,reservationId,note,commentaire,const DeepCollectionEquality().hash(_photoUrls),createdAt);

@override
String toString() {
  return 'Avis(id: $id, clientId: $clientId, prestataireId: $prestataireId, reservationId: $reservationId, note: $note, commentaire: $commentaire, photoUrls: $photoUrls, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AvisCopyWith<$Res> implements $AvisCopyWith<$Res> {
  factory _$AvisCopyWith(_Avis value, $Res Function(_Avis) _then) = __$AvisCopyWithImpl;
@override @useResult
$Res call({
 String id, String clientId, String prestataireId, String reservationId, int note, String? commentaire,@JsonKey(name: 'photo_urls') List<String> photoUrls,@IsoDateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class __$AvisCopyWithImpl<$Res>
    implements _$AvisCopyWith<$Res> {
  __$AvisCopyWithImpl(this._self, this._then);

  final _Avis _self;
  final $Res Function(_Avis) _then;

/// Create a copy of Avis
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? clientId = null,Object? prestataireId = null,Object? reservationId = null,Object? note = null,Object? commentaire = freezed,Object? photoUrls = null,Object? createdAt = null,}) {
  return _then(_Avis(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,reservationId: null == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as int,commentaire: freezed == commentaire ? _self.commentaire : commentaire // ignore: cast_nullable_to_non_nullable
as String?,photoUrls: null == photoUrls ? _self._photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

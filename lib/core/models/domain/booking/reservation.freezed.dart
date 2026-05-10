// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Reservation {

 String get id; String get clientId; String get prestataireId; String get serviceId;@IsoDateTimeConverter() DateTime get dateHeure; String get statut; String? get notesClient;@IsoDateTimeConverter() DateTime get createdAt;
/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReservationCopyWith<Reservation> get copyWith => _$ReservationCopyWithImpl<Reservation>(this as Reservation, _$identity);

  /// Serializes this Reservation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reservation&&(identical(other.id, id) || other.id == id)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.dateHeure, dateHeure) || other.dateHeure == dateHeure)&&(identical(other.statut, statut) || other.statut == statut)&&(identical(other.notesClient, notesClient) || other.notesClient == notesClient)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,clientId,prestataireId,serviceId,dateHeure,statut,notesClient,createdAt);

@override
String toString() {
  return 'Reservation(id: $id, clientId: $clientId, prestataireId: $prestataireId, serviceId: $serviceId, dateHeure: $dateHeure, statut: $statut, notesClient: $notesClient, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ReservationCopyWith<$Res>  {
  factory $ReservationCopyWith(Reservation value, $Res Function(Reservation) _then) = _$ReservationCopyWithImpl;
@useResult
$Res call({
 String id, String clientId, String prestataireId, String serviceId,@IsoDateTimeConverter() DateTime dateHeure, String statut, String? notesClient,@IsoDateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class _$ReservationCopyWithImpl<$Res>
    implements $ReservationCopyWith<$Res> {
  _$ReservationCopyWithImpl(this._self, this._then);

  final Reservation _self;
  final $Res Function(Reservation) _then;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? clientId = null,Object? prestataireId = null,Object? serviceId = null,Object? dateHeure = null,Object? statut = null,Object? notesClient = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,dateHeure: null == dateHeure ? _self.dateHeure : dateHeure // ignore: cast_nullable_to_non_nullable
as DateTime,statut: null == statut ? _self.statut : statut // ignore: cast_nullable_to_non_nullable
as String,notesClient: freezed == notesClient ? _self.notesClient : notesClient // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Reservation].
extension ReservationPatterns on Reservation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reservation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reservation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reservation value)  $default,){
final _that = this;
switch (_that) {
case _Reservation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reservation value)?  $default,){
final _that = this;
switch (_that) {
case _Reservation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String clientId,  String prestataireId,  String serviceId, @IsoDateTimeConverter()  DateTime dateHeure,  String statut,  String? notesClient, @IsoDateTimeConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reservation() when $default != null:
return $default(_that.id,_that.clientId,_that.prestataireId,_that.serviceId,_that.dateHeure,_that.statut,_that.notesClient,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String clientId,  String prestataireId,  String serviceId, @IsoDateTimeConverter()  DateTime dateHeure,  String statut,  String? notesClient, @IsoDateTimeConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Reservation():
return $default(_that.id,_that.clientId,_that.prestataireId,_that.serviceId,_that.dateHeure,_that.statut,_that.notesClient,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String clientId,  String prestataireId,  String serviceId, @IsoDateTimeConverter()  DateTime dateHeure,  String statut,  String? notesClient, @IsoDateTimeConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Reservation() when $default != null:
return $default(_that.id,_that.clientId,_that.prestataireId,_that.serviceId,_that.dateHeure,_that.statut,_that.notesClient,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Reservation implements Reservation {
  const _Reservation({required this.id, required this.clientId, required this.prestataireId, required this.serviceId, @IsoDateTimeConverter() required this.dateHeure, required this.statut, this.notesClient, @IsoDateTimeConverter() required this.createdAt});
  factory _Reservation.fromJson(Map<String, dynamic> json) => _$ReservationFromJson(json);

@override final  String id;
@override final  String clientId;
@override final  String prestataireId;
@override final  String serviceId;
@override@IsoDateTimeConverter() final  DateTime dateHeure;
@override final  String statut;
@override final  String? notesClient;
@override@IsoDateTimeConverter() final  DateTime createdAt;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReservationCopyWith<_Reservation> get copyWith => __$ReservationCopyWithImpl<_Reservation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReservationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reservation&&(identical(other.id, id) || other.id == id)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.dateHeure, dateHeure) || other.dateHeure == dateHeure)&&(identical(other.statut, statut) || other.statut == statut)&&(identical(other.notesClient, notesClient) || other.notesClient == notesClient)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,clientId,prestataireId,serviceId,dateHeure,statut,notesClient,createdAt);

@override
String toString() {
  return 'Reservation(id: $id, clientId: $clientId, prestataireId: $prestataireId, serviceId: $serviceId, dateHeure: $dateHeure, statut: $statut, notesClient: $notesClient, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ReservationCopyWith<$Res> implements $ReservationCopyWith<$Res> {
  factory _$ReservationCopyWith(_Reservation value, $Res Function(_Reservation) _then) = __$ReservationCopyWithImpl;
@override @useResult
$Res call({
 String id, String clientId, String prestataireId, String serviceId,@IsoDateTimeConverter() DateTime dateHeure, String statut, String? notesClient,@IsoDateTimeConverter() DateTime createdAt
});




}
/// @nodoc
class __$ReservationCopyWithImpl<$Res>
    implements _$ReservationCopyWith<$Res> {
  __$ReservationCopyWithImpl(this._self, this._then);

  final _Reservation _self;
  final $Res Function(_Reservation) _then;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? clientId = null,Object? prestataireId = null,Object? serviceId = null,Object? dateHeure = null,Object? statut = null,Object? notesClient = freezed,Object? createdAt = null,}) {
  return _then(_Reservation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,dateHeure: null == dateHeure ? _self.dateHeure : dateHeure // ignore: cast_nullable_to_non_nullable
as DateTime,statut: null == statut ? _self.statut : statut // ignore: cast_nullable_to_non_nullable
as String,notesClient: freezed == notesClient ? _self.notesClient : notesClient // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

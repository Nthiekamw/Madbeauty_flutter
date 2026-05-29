// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stats_prestataire.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StatsChartPoint {

 String get label; int get revenueCents;
/// Create a copy of StatsChartPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsChartPointCopyWith<StatsChartPoint> get copyWith => _$StatsChartPointCopyWithImpl<StatsChartPoint>(this as StatsChartPoint, _$identity);

  /// Serializes this StatsChartPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsChartPoint&&(identical(other.label, label) || other.label == label)&&(identical(other.revenueCents, revenueCents) || other.revenueCents == revenueCents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,revenueCents);

@override
String toString() {
  return 'StatsChartPoint(label: $label, revenueCents: $revenueCents)';
}


}

/// @nodoc
abstract mixin class $StatsChartPointCopyWith<$Res>  {
  factory $StatsChartPointCopyWith(StatsChartPoint value, $Res Function(StatsChartPoint) _then) = _$StatsChartPointCopyWithImpl;
@useResult
$Res call({
 String label, int revenueCents
});




}
/// @nodoc
class _$StatsChartPointCopyWithImpl<$Res>
    implements $StatsChartPointCopyWith<$Res> {
  _$StatsChartPointCopyWithImpl(this._self, this._then);

  final StatsChartPoint _self;
  final $Res Function(StatsChartPoint) _then;

/// Create a copy of StatsChartPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? revenueCents = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,revenueCents: null == revenueCents ? _self.revenueCents : revenueCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StatsChartPoint].
extension StatsChartPointPatterns on StatsChartPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsChartPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsChartPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsChartPoint value)  $default,){
final _that = this;
switch (_that) {
case _StatsChartPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsChartPoint value)?  $default,){
final _that = this;
switch (_that) {
case _StatsChartPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  int revenueCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsChartPoint() when $default != null:
return $default(_that.label,_that.revenueCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  int revenueCents)  $default,) {final _that = this;
switch (_that) {
case _StatsChartPoint():
return $default(_that.label,_that.revenueCents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  int revenueCents)?  $default,) {final _that = this;
switch (_that) {
case _StatsChartPoint() when $default != null:
return $default(_that.label,_that.revenueCents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatsChartPoint implements StatsChartPoint {
  const _StatsChartPoint({required this.label, required this.revenueCents});
  factory _StatsChartPoint.fromJson(Map<String, dynamic> json) => _$StatsChartPointFromJson(json);

@override final  String label;
@override final  int revenueCents;

/// Create a copy of StatsChartPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsChartPointCopyWith<_StatsChartPoint> get copyWith => __$StatsChartPointCopyWithImpl<_StatsChartPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatsChartPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsChartPoint&&(identical(other.label, label) || other.label == label)&&(identical(other.revenueCents, revenueCents) || other.revenueCents == revenueCents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,revenueCents);

@override
String toString() {
  return 'StatsChartPoint(label: $label, revenueCents: $revenueCents)';
}


}

/// @nodoc
abstract mixin class _$StatsChartPointCopyWith<$Res> implements $StatsChartPointCopyWith<$Res> {
  factory _$StatsChartPointCopyWith(_StatsChartPoint value, $Res Function(_StatsChartPoint) _then) = __$StatsChartPointCopyWithImpl;
@override @useResult
$Res call({
 String label, int revenueCents
});




}
/// @nodoc
class __$StatsChartPointCopyWithImpl<$Res>
    implements _$StatsChartPointCopyWith<$Res> {
  __$StatsChartPointCopyWithImpl(this._self, this._then);

  final _StatsChartPoint _self;
  final $Res Function(_StatsChartPoint) _then;

/// Create a copy of StatsChartPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? revenueCents = null,}) {
  return _then(_StatsChartPoint(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,revenueCents: null == revenueCents ? _self.revenueCents : revenueCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$StatsWeeklyRevenue {

 String get weekStart; String get label; int get revenueCents;
/// Create a copy of StatsWeeklyRevenue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsWeeklyRevenueCopyWith<StatsWeeklyRevenue> get copyWith => _$StatsWeeklyRevenueCopyWithImpl<StatsWeeklyRevenue>(this as StatsWeeklyRevenue, _$identity);

  /// Serializes this StatsWeeklyRevenue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsWeeklyRevenue&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart)&&(identical(other.label, label) || other.label == label)&&(identical(other.revenueCents, revenueCents) || other.revenueCents == revenueCents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weekStart,label,revenueCents);

@override
String toString() {
  return 'StatsWeeklyRevenue(weekStart: $weekStart, label: $label, revenueCents: $revenueCents)';
}


}

/// @nodoc
abstract mixin class $StatsWeeklyRevenueCopyWith<$Res>  {
  factory $StatsWeeklyRevenueCopyWith(StatsWeeklyRevenue value, $Res Function(StatsWeeklyRevenue) _then) = _$StatsWeeklyRevenueCopyWithImpl;
@useResult
$Res call({
 String weekStart, String label, int revenueCents
});




}
/// @nodoc
class _$StatsWeeklyRevenueCopyWithImpl<$Res>
    implements $StatsWeeklyRevenueCopyWith<$Res> {
  _$StatsWeeklyRevenueCopyWithImpl(this._self, this._then);

  final StatsWeeklyRevenue _self;
  final $Res Function(StatsWeeklyRevenue) _then;

/// Create a copy of StatsWeeklyRevenue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weekStart = null,Object? label = null,Object? revenueCents = null,}) {
  return _then(_self.copyWith(
weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,revenueCents: null == revenueCents ? _self.revenueCents : revenueCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StatsWeeklyRevenue].
extension StatsWeeklyRevenuePatterns on StatsWeeklyRevenue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsWeeklyRevenue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsWeeklyRevenue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsWeeklyRevenue value)  $default,){
final _that = this;
switch (_that) {
case _StatsWeeklyRevenue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsWeeklyRevenue value)?  $default,){
final _that = this;
switch (_that) {
case _StatsWeeklyRevenue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String weekStart,  String label,  int revenueCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsWeeklyRevenue() when $default != null:
return $default(_that.weekStart,_that.label,_that.revenueCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String weekStart,  String label,  int revenueCents)  $default,) {final _that = this;
switch (_that) {
case _StatsWeeklyRevenue():
return $default(_that.weekStart,_that.label,_that.revenueCents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String weekStart,  String label,  int revenueCents)?  $default,) {final _that = this;
switch (_that) {
case _StatsWeeklyRevenue() when $default != null:
return $default(_that.weekStart,_that.label,_that.revenueCents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatsWeeklyRevenue implements StatsWeeklyRevenue {
  const _StatsWeeklyRevenue({required this.weekStart, required this.label, required this.revenueCents});
  factory _StatsWeeklyRevenue.fromJson(Map<String, dynamic> json) => _$StatsWeeklyRevenueFromJson(json);

@override final  String weekStart;
@override final  String label;
@override final  int revenueCents;

/// Create a copy of StatsWeeklyRevenue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsWeeklyRevenueCopyWith<_StatsWeeklyRevenue> get copyWith => __$StatsWeeklyRevenueCopyWithImpl<_StatsWeeklyRevenue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatsWeeklyRevenueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsWeeklyRevenue&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart)&&(identical(other.label, label) || other.label == label)&&(identical(other.revenueCents, revenueCents) || other.revenueCents == revenueCents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weekStart,label,revenueCents);

@override
String toString() {
  return 'StatsWeeklyRevenue(weekStart: $weekStart, label: $label, revenueCents: $revenueCents)';
}


}

/// @nodoc
abstract mixin class _$StatsWeeklyRevenueCopyWith<$Res> implements $StatsWeeklyRevenueCopyWith<$Res> {
  factory _$StatsWeeklyRevenueCopyWith(_StatsWeeklyRevenue value, $Res Function(_StatsWeeklyRevenue) _then) = __$StatsWeeklyRevenueCopyWithImpl;
@override @useResult
$Res call({
 String weekStart, String label, int revenueCents
});




}
/// @nodoc
class __$StatsWeeklyRevenueCopyWithImpl<$Res>
    implements _$StatsWeeklyRevenueCopyWith<$Res> {
  __$StatsWeeklyRevenueCopyWithImpl(this._self, this._then);

  final _StatsWeeklyRevenue _self;
  final $Res Function(_StatsWeeklyRevenue) _then;

/// Create a copy of StatsWeeklyRevenue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weekStart = null,Object? label = null,Object? revenueCents = null,}) {
  return _then(_StatsWeeklyRevenue(
weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,revenueCents: null == revenueCents ? _self.revenueCents : revenueCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$StatsPrestataire {

 String get prestataireId; int get periodDays; int get caPeriodCents; int get caPreviousPeriodCents; int get bookingsPending; int get bookingsConfirmed; int get bookingsDone; int get bookingsCancelled; int get bookingsTotal; double get occupancyPercent; int get capacitySlots; int get bookedSlots; List<double> get weekdayHeatmap; int? get busiestWeekday;@JsonKey(name: 'weekly_revenue_3m') List<StatsWeeklyRevenue> get weeklyRevenue3m; List<StatsChartPoint> get chart;
/// Create a copy of StatsPrestataire
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsPrestataireCopyWith<StatsPrestataire> get copyWith => _$StatsPrestataireCopyWithImpl<StatsPrestataire>(this as StatsPrestataire, _$identity);

  /// Serializes this StatsPrestataire to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsPrestataire&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.periodDays, periodDays) || other.periodDays == periodDays)&&(identical(other.caPeriodCents, caPeriodCents) || other.caPeriodCents == caPeriodCents)&&(identical(other.caPreviousPeriodCents, caPreviousPeriodCents) || other.caPreviousPeriodCents == caPreviousPeriodCents)&&(identical(other.bookingsPending, bookingsPending) || other.bookingsPending == bookingsPending)&&(identical(other.bookingsConfirmed, bookingsConfirmed) || other.bookingsConfirmed == bookingsConfirmed)&&(identical(other.bookingsDone, bookingsDone) || other.bookingsDone == bookingsDone)&&(identical(other.bookingsCancelled, bookingsCancelled) || other.bookingsCancelled == bookingsCancelled)&&(identical(other.bookingsTotal, bookingsTotal) || other.bookingsTotal == bookingsTotal)&&(identical(other.occupancyPercent, occupancyPercent) || other.occupancyPercent == occupancyPercent)&&(identical(other.capacitySlots, capacitySlots) || other.capacitySlots == capacitySlots)&&(identical(other.bookedSlots, bookedSlots) || other.bookedSlots == bookedSlots)&&const DeepCollectionEquality().equals(other.weekdayHeatmap, weekdayHeatmap)&&(identical(other.busiestWeekday, busiestWeekday) || other.busiestWeekday == busiestWeekday)&&const DeepCollectionEquality().equals(other.weeklyRevenue3m, weeklyRevenue3m)&&const DeepCollectionEquality().equals(other.chart, chart));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prestataireId,periodDays,caPeriodCents,caPreviousPeriodCents,bookingsPending,bookingsConfirmed,bookingsDone,bookingsCancelled,bookingsTotal,occupancyPercent,capacitySlots,bookedSlots,const DeepCollectionEquality().hash(weekdayHeatmap),busiestWeekday,const DeepCollectionEquality().hash(weeklyRevenue3m),const DeepCollectionEquality().hash(chart));

@override
String toString() {
  return 'StatsPrestataire(prestataireId: $prestataireId, periodDays: $periodDays, caPeriodCents: $caPeriodCents, caPreviousPeriodCents: $caPreviousPeriodCents, bookingsPending: $bookingsPending, bookingsConfirmed: $bookingsConfirmed, bookingsDone: $bookingsDone, bookingsCancelled: $bookingsCancelled, bookingsTotal: $bookingsTotal, occupancyPercent: $occupancyPercent, capacitySlots: $capacitySlots, bookedSlots: $bookedSlots, weekdayHeatmap: $weekdayHeatmap, busiestWeekday: $busiestWeekday, weeklyRevenue3m: $weeklyRevenue3m, chart: $chart)';
}


}

/// @nodoc
abstract mixin class $StatsPrestataireCopyWith<$Res>  {
  factory $StatsPrestataireCopyWith(StatsPrestataire value, $Res Function(StatsPrestataire) _then) = _$StatsPrestataireCopyWithImpl;
@useResult
$Res call({
 String prestataireId, int periodDays, int caPeriodCents, int caPreviousPeriodCents, int bookingsPending, int bookingsConfirmed, int bookingsDone, int bookingsCancelled, int bookingsTotal, double occupancyPercent, int capacitySlots, int bookedSlots, List<double> weekdayHeatmap, int? busiestWeekday,@JsonKey(name: 'weekly_revenue_3m') List<StatsWeeklyRevenue> weeklyRevenue3m, List<StatsChartPoint> chart
});




}
/// @nodoc
class _$StatsPrestataireCopyWithImpl<$Res>
    implements $StatsPrestataireCopyWith<$Res> {
  _$StatsPrestataireCopyWithImpl(this._self, this._then);

  final StatsPrestataire _self;
  final $Res Function(StatsPrestataire) _then;

/// Create a copy of StatsPrestataire
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? prestataireId = null,Object? periodDays = null,Object? caPeriodCents = null,Object? caPreviousPeriodCents = null,Object? bookingsPending = null,Object? bookingsConfirmed = null,Object? bookingsDone = null,Object? bookingsCancelled = null,Object? bookingsTotal = null,Object? occupancyPercent = null,Object? capacitySlots = null,Object? bookedSlots = null,Object? weekdayHeatmap = null,Object? busiestWeekday = freezed,Object? weeklyRevenue3m = null,Object? chart = null,}) {
  return _then(_self.copyWith(
prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,periodDays: null == periodDays ? _self.periodDays : periodDays // ignore: cast_nullable_to_non_nullable
as int,caPeriodCents: null == caPeriodCents ? _self.caPeriodCents : caPeriodCents // ignore: cast_nullable_to_non_nullable
as int,caPreviousPeriodCents: null == caPreviousPeriodCents ? _self.caPreviousPeriodCents : caPreviousPeriodCents // ignore: cast_nullable_to_non_nullable
as int,bookingsPending: null == bookingsPending ? _self.bookingsPending : bookingsPending // ignore: cast_nullable_to_non_nullable
as int,bookingsConfirmed: null == bookingsConfirmed ? _self.bookingsConfirmed : bookingsConfirmed // ignore: cast_nullable_to_non_nullable
as int,bookingsDone: null == bookingsDone ? _self.bookingsDone : bookingsDone // ignore: cast_nullable_to_non_nullable
as int,bookingsCancelled: null == bookingsCancelled ? _self.bookingsCancelled : bookingsCancelled // ignore: cast_nullable_to_non_nullable
as int,bookingsTotal: null == bookingsTotal ? _self.bookingsTotal : bookingsTotal // ignore: cast_nullable_to_non_nullable
as int,occupancyPercent: null == occupancyPercent ? _self.occupancyPercent : occupancyPercent // ignore: cast_nullable_to_non_nullable
as double,capacitySlots: null == capacitySlots ? _self.capacitySlots : capacitySlots // ignore: cast_nullable_to_non_nullable
as int,bookedSlots: null == bookedSlots ? _self.bookedSlots : bookedSlots // ignore: cast_nullable_to_non_nullable
as int,weekdayHeatmap: null == weekdayHeatmap ? _self.weekdayHeatmap : weekdayHeatmap // ignore: cast_nullable_to_non_nullable
as List<double>,busiestWeekday: freezed == busiestWeekday ? _self.busiestWeekday : busiestWeekday // ignore: cast_nullable_to_non_nullable
as int?,weeklyRevenue3m: null == weeklyRevenue3m ? _self.weeklyRevenue3m : weeklyRevenue3m // ignore: cast_nullable_to_non_nullable
as List<StatsWeeklyRevenue>,chart: null == chart ? _self.chart : chart // ignore: cast_nullable_to_non_nullable
as List<StatsChartPoint>,
  ));
}

}


/// Adds pattern-matching-related methods to [StatsPrestataire].
extension StatsPrestatairePatterns on StatsPrestataire {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsPrestataire value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsPrestataire() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsPrestataire value)  $default,){
final _that = this;
switch (_that) {
case _StatsPrestataire():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsPrestataire value)?  $default,){
final _that = this;
switch (_that) {
case _StatsPrestataire() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String prestataireId,  int periodDays,  int caPeriodCents,  int caPreviousPeriodCents,  int bookingsPending,  int bookingsConfirmed,  int bookingsDone,  int bookingsCancelled,  int bookingsTotal,  double occupancyPercent,  int capacitySlots,  int bookedSlots,  List<double> weekdayHeatmap,  int? busiestWeekday, @JsonKey(name: 'weekly_revenue_3m')  List<StatsWeeklyRevenue> weeklyRevenue3m,  List<StatsChartPoint> chart)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsPrestataire() when $default != null:
return $default(_that.prestataireId,_that.periodDays,_that.caPeriodCents,_that.caPreviousPeriodCents,_that.bookingsPending,_that.bookingsConfirmed,_that.bookingsDone,_that.bookingsCancelled,_that.bookingsTotal,_that.occupancyPercent,_that.capacitySlots,_that.bookedSlots,_that.weekdayHeatmap,_that.busiestWeekday,_that.weeklyRevenue3m,_that.chart);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String prestataireId,  int periodDays,  int caPeriodCents,  int caPreviousPeriodCents,  int bookingsPending,  int bookingsConfirmed,  int bookingsDone,  int bookingsCancelled,  int bookingsTotal,  double occupancyPercent,  int capacitySlots,  int bookedSlots,  List<double> weekdayHeatmap,  int? busiestWeekday, @JsonKey(name: 'weekly_revenue_3m')  List<StatsWeeklyRevenue> weeklyRevenue3m,  List<StatsChartPoint> chart)  $default,) {final _that = this;
switch (_that) {
case _StatsPrestataire():
return $default(_that.prestataireId,_that.periodDays,_that.caPeriodCents,_that.caPreviousPeriodCents,_that.bookingsPending,_that.bookingsConfirmed,_that.bookingsDone,_that.bookingsCancelled,_that.bookingsTotal,_that.occupancyPercent,_that.capacitySlots,_that.bookedSlots,_that.weekdayHeatmap,_that.busiestWeekday,_that.weeklyRevenue3m,_that.chart);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String prestataireId,  int periodDays,  int caPeriodCents,  int caPreviousPeriodCents,  int bookingsPending,  int bookingsConfirmed,  int bookingsDone,  int bookingsCancelled,  int bookingsTotal,  double occupancyPercent,  int capacitySlots,  int bookedSlots,  List<double> weekdayHeatmap,  int? busiestWeekday, @JsonKey(name: 'weekly_revenue_3m')  List<StatsWeeklyRevenue> weeklyRevenue3m,  List<StatsChartPoint> chart)?  $default,) {final _that = this;
switch (_that) {
case _StatsPrestataire() when $default != null:
return $default(_that.prestataireId,_that.periodDays,_that.caPeriodCents,_that.caPreviousPeriodCents,_that.bookingsPending,_that.bookingsConfirmed,_that.bookingsDone,_that.bookingsCancelled,_that.bookingsTotal,_that.occupancyPercent,_that.capacitySlots,_that.bookedSlots,_that.weekdayHeatmap,_that.busiestWeekday,_that.weeklyRevenue3m,_that.chart);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatsPrestataire implements StatsPrestataire {
  const _StatsPrestataire({required this.prestataireId, required this.periodDays, required this.caPeriodCents, required this.caPreviousPeriodCents, required this.bookingsPending, required this.bookingsConfirmed, required this.bookingsDone, required this.bookingsCancelled, required this.bookingsTotal, required this.occupancyPercent, required this.capacitySlots, required this.bookedSlots, required final  List<double> weekdayHeatmap, this.busiestWeekday, @JsonKey(name: 'weekly_revenue_3m') final  List<StatsWeeklyRevenue> weeklyRevenue3m = const [], final  List<StatsChartPoint> chart = const []}): _weekdayHeatmap = weekdayHeatmap,_weeklyRevenue3m = weeklyRevenue3m,_chart = chart;
  factory _StatsPrestataire.fromJson(Map<String, dynamic> json) => _$StatsPrestataireFromJson(json);

@override final  String prestataireId;
@override final  int periodDays;
@override final  int caPeriodCents;
@override final  int caPreviousPeriodCents;
@override final  int bookingsPending;
@override final  int bookingsConfirmed;
@override final  int bookingsDone;
@override final  int bookingsCancelled;
@override final  int bookingsTotal;
@override final  double occupancyPercent;
@override final  int capacitySlots;
@override final  int bookedSlots;
 final  List<double> _weekdayHeatmap;
@override List<double> get weekdayHeatmap {
  if (_weekdayHeatmap is EqualUnmodifiableListView) return _weekdayHeatmap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weekdayHeatmap);
}

@override final  int? busiestWeekday;
 final  List<StatsWeeklyRevenue> _weeklyRevenue3m;
@override@JsonKey(name: 'weekly_revenue_3m') List<StatsWeeklyRevenue> get weeklyRevenue3m {
  if (_weeklyRevenue3m is EqualUnmodifiableListView) return _weeklyRevenue3m;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weeklyRevenue3m);
}

 final  List<StatsChartPoint> _chart;
@override@JsonKey() List<StatsChartPoint> get chart {
  if (_chart is EqualUnmodifiableListView) return _chart;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chart);
}


/// Create a copy of StatsPrestataire
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsPrestataireCopyWith<_StatsPrestataire> get copyWith => __$StatsPrestataireCopyWithImpl<_StatsPrestataire>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatsPrestataireToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsPrestataire&&(identical(other.prestataireId, prestataireId) || other.prestataireId == prestataireId)&&(identical(other.periodDays, periodDays) || other.periodDays == periodDays)&&(identical(other.caPeriodCents, caPeriodCents) || other.caPeriodCents == caPeriodCents)&&(identical(other.caPreviousPeriodCents, caPreviousPeriodCents) || other.caPreviousPeriodCents == caPreviousPeriodCents)&&(identical(other.bookingsPending, bookingsPending) || other.bookingsPending == bookingsPending)&&(identical(other.bookingsConfirmed, bookingsConfirmed) || other.bookingsConfirmed == bookingsConfirmed)&&(identical(other.bookingsDone, bookingsDone) || other.bookingsDone == bookingsDone)&&(identical(other.bookingsCancelled, bookingsCancelled) || other.bookingsCancelled == bookingsCancelled)&&(identical(other.bookingsTotal, bookingsTotal) || other.bookingsTotal == bookingsTotal)&&(identical(other.occupancyPercent, occupancyPercent) || other.occupancyPercent == occupancyPercent)&&(identical(other.capacitySlots, capacitySlots) || other.capacitySlots == capacitySlots)&&(identical(other.bookedSlots, bookedSlots) || other.bookedSlots == bookedSlots)&&const DeepCollectionEquality().equals(other._weekdayHeatmap, _weekdayHeatmap)&&(identical(other.busiestWeekday, busiestWeekday) || other.busiestWeekday == busiestWeekday)&&const DeepCollectionEquality().equals(other._weeklyRevenue3m, _weeklyRevenue3m)&&const DeepCollectionEquality().equals(other._chart, _chart));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prestataireId,periodDays,caPeriodCents,caPreviousPeriodCents,bookingsPending,bookingsConfirmed,bookingsDone,bookingsCancelled,bookingsTotal,occupancyPercent,capacitySlots,bookedSlots,const DeepCollectionEquality().hash(_weekdayHeatmap),busiestWeekday,const DeepCollectionEquality().hash(_weeklyRevenue3m),const DeepCollectionEquality().hash(_chart));

@override
String toString() {
  return 'StatsPrestataire(prestataireId: $prestataireId, periodDays: $periodDays, caPeriodCents: $caPeriodCents, caPreviousPeriodCents: $caPreviousPeriodCents, bookingsPending: $bookingsPending, bookingsConfirmed: $bookingsConfirmed, bookingsDone: $bookingsDone, bookingsCancelled: $bookingsCancelled, bookingsTotal: $bookingsTotal, occupancyPercent: $occupancyPercent, capacitySlots: $capacitySlots, bookedSlots: $bookedSlots, weekdayHeatmap: $weekdayHeatmap, busiestWeekday: $busiestWeekday, weeklyRevenue3m: $weeklyRevenue3m, chart: $chart)';
}


}

/// @nodoc
abstract mixin class _$StatsPrestataireCopyWith<$Res> implements $StatsPrestataireCopyWith<$Res> {
  factory _$StatsPrestataireCopyWith(_StatsPrestataire value, $Res Function(_StatsPrestataire) _then) = __$StatsPrestataireCopyWithImpl;
@override @useResult
$Res call({
 String prestataireId, int periodDays, int caPeriodCents, int caPreviousPeriodCents, int bookingsPending, int bookingsConfirmed, int bookingsDone, int bookingsCancelled, int bookingsTotal, double occupancyPercent, int capacitySlots, int bookedSlots, List<double> weekdayHeatmap, int? busiestWeekday,@JsonKey(name: 'weekly_revenue_3m') List<StatsWeeklyRevenue> weeklyRevenue3m, List<StatsChartPoint> chart
});




}
/// @nodoc
class __$StatsPrestataireCopyWithImpl<$Res>
    implements _$StatsPrestataireCopyWith<$Res> {
  __$StatsPrestataireCopyWithImpl(this._self, this._then);

  final _StatsPrestataire _self;
  final $Res Function(_StatsPrestataire) _then;

/// Create a copy of StatsPrestataire
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? prestataireId = null,Object? periodDays = null,Object? caPeriodCents = null,Object? caPreviousPeriodCents = null,Object? bookingsPending = null,Object? bookingsConfirmed = null,Object? bookingsDone = null,Object? bookingsCancelled = null,Object? bookingsTotal = null,Object? occupancyPercent = null,Object? capacitySlots = null,Object? bookedSlots = null,Object? weekdayHeatmap = null,Object? busiestWeekday = freezed,Object? weeklyRevenue3m = null,Object? chart = null,}) {
  return _then(_StatsPrestataire(
prestataireId: null == prestataireId ? _self.prestataireId : prestataireId // ignore: cast_nullable_to_non_nullable
as String,periodDays: null == periodDays ? _self.periodDays : periodDays // ignore: cast_nullable_to_non_nullable
as int,caPeriodCents: null == caPeriodCents ? _self.caPeriodCents : caPeriodCents // ignore: cast_nullable_to_non_nullable
as int,caPreviousPeriodCents: null == caPreviousPeriodCents ? _self.caPreviousPeriodCents : caPreviousPeriodCents // ignore: cast_nullable_to_non_nullable
as int,bookingsPending: null == bookingsPending ? _self.bookingsPending : bookingsPending // ignore: cast_nullable_to_non_nullable
as int,bookingsConfirmed: null == bookingsConfirmed ? _self.bookingsConfirmed : bookingsConfirmed // ignore: cast_nullable_to_non_nullable
as int,bookingsDone: null == bookingsDone ? _self.bookingsDone : bookingsDone // ignore: cast_nullable_to_non_nullable
as int,bookingsCancelled: null == bookingsCancelled ? _self.bookingsCancelled : bookingsCancelled // ignore: cast_nullable_to_non_nullable
as int,bookingsTotal: null == bookingsTotal ? _self.bookingsTotal : bookingsTotal // ignore: cast_nullable_to_non_nullable
as int,occupancyPercent: null == occupancyPercent ? _self.occupancyPercent : occupancyPercent // ignore: cast_nullable_to_non_nullable
as double,capacitySlots: null == capacitySlots ? _self.capacitySlots : capacitySlots // ignore: cast_nullable_to_non_nullable
as int,bookedSlots: null == bookedSlots ? _self.bookedSlots : bookedSlots // ignore: cast_nullable_to_non_nullable
as int,weekdayHeatmap: null == weekdayHeatmap ? _self._weekdayHeatmap : weekdayHeatmap // ignore: cast_nullable_to_non_nullable
as List<double>,busiestWeekday: freezed == busiestWeekday ? _self.busiestWeekday : busiestWeekday // ignore: cast_nullable_to_non_nullable
as int?,weeklyRevenue3m: null == weeklyRevenue3m ? _self._weeklyRevenue3m : weeklyRevenue3m // ignore: cast_nullable_to_non_nullable
as List<StatsWeeklyRevenue>,chart: null == chart ? _self._chart : chart // ignore: cast_nullable_to_non_nullable
as List<StatsChartPoint>,
  ));
}


}

// dart format on

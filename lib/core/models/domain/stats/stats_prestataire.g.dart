// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_prestataire.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StatsChartPoint _$StatsChartPointFromJson(Map<String, dynamic> json) =>
    _StatsChartPoint(
      label: json['label'] as String,
      revenueCents: (json['revenue_cents'] as num).toInt(),
    );

Map<String, dynamic> _$StatsChartPointToJson(_StatsChartPoint instance) =>
    <String, dynamic>{
      'label': instance.label,
      'revenue_cents': instance.revenueCents,
    };

_StatsWeeklyRevenue _$StatsWeeklyRevenueFromJson(Map<String, dynamic> json) =>
    _StatsWeeklyRevenue(
      weekStart: json['week_start'] as String,
      label: json['label'] as String,
      revenueCents: (json['revenue_cents'] as num).toInt(),
    );

Map<String, dynamic> _$StatsWeeklyRevenueToJson(_StatsWeeklyRevenue instance) =>
    <String, dynamic>{
      'week_start': instance.weekStart,
      'label': instance.label,
      'revenue_cents': instance.revenueCents,
    };

_StatsPrestataire _$StatsPrestataireFromJson(Map<String, dynamic> json) =>
    _StatsPrestataire(
      prestataireId: json['prestataire_id'] as String,
      periodDays: (json['period_days'] as num).toInt(),
      caPeriodCents: (json['ca_period_cents'] as num).toInt(),
      caPreviousPeriodCents: (json['ca_previous_period_cents'] as num).toInt(),
      bookingsPending: (json['bookings_pending'] as num).toInt(),
      bookingsConfirmed: (json['bookings_confirmed'] as num).toInt(),
      bookingsDone: (json['bookings_done'] as num).toInt(),
      bookingsCancelled: (json['bookings_cancelled'] as num).toInt(),
      bookingsTotal: (json['bookings_total'] as num).toInt(),
      occupancyPercent: (json['occupancy_percent'] as num).toDouble(),
      capacitySlots: (json['capacity_slots'] as num).toInt(),
      bookedSlots: (json['booked_slots'] as num).toInt(),
      weekdayHeatmap: (json['weekday_heatmap'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      busiestWeekday: (json['busiest_weekday'] as num?)?.toInt(),
      weeklyRevenue3m:
          (json['weekly_revenue_3m'] as List<dynamic>?)
              ?.map(
                (e) => StatsWeeklyRevenue.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      chart:
          (json['chart'] as List<dynamic>?)
              ?.map((e) => StatsChartPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$StatsPrestataireToJson(
  _StatsPrestataire instance,
) => <String, dynamic>{
  'prestataire_id': instance.prestataireId,
  'period_days': instance.periodDays,
  'ca_period_cents': instance.caPeriodCents,
  'ca_previous_period_cents': instance.caPreviousPeriodCents,
  'bookings_pending': instance.bookingsPending,
  'bookings_confirmed': instance.bookingsConfirmed,
  'bookings_done': instance.bookingsDone,
  'bookings_cancelled': instance.bookingsCancelled,
  'bookings_total': instance.bookingsTotal,
  'occupancy_percent': instance.occupancyPercent,
  'capacity_slots': instance.capacitySlots,
  'booked_slots': instance.bookedSlots,
  'weekday_heatmap': instance.weekdayHeatmap,
  'busiest_weekday': instance.busiestWeekday,
  'weekly_revenue_3m': instance.weeklyRevenue3m.map((e) => e.toJson()).toList(),
  'chart': instance.chart.map((e) => e.toJson()).toList(),
};

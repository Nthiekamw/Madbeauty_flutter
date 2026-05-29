import 'package:freezed_annotation/freezed_annotation.dart';

part 'stats_prestataire.freezed.dart';
part 'stats_prestataire.g.dart';

/// Point du graphique CA (période filtrée).
@freezed
abstract class StatsChartPoint with _$StatsChartPoint {
  const factory StatsChartPoint({
    required String label,
    required int revenueCents,
  }) = _StatsChartPoint;

  factory StatsChartPoint.fromJson(Map<String, dynamic> json) =>
      _$StatsChartPointFromJson(json);
}

/// Revenus hebdomadaires sur les 3 derniers mois.
@freezed
abstract class StatsWeeklyRevenue with _$StatsWeeklyRevenue {
  const factory StatsWeeklyRevenue({
    required String weekStart,
    required String label,
    required int revenueCents,
  }) = _StatsWeeklyRevenue;

  factory StatsWeeklyRevenue.fromJson(Map<String, dynamic> json) =>
      _$StatsWeeklyRevenueFromJson(json);
}

/// Agrégats renvoyés par `get_prestataire_stats` (Supabase).
@freezed
abstract class StatsPrestataire with _$StatsPrestataire {
  const factory StatsPrestataire({
    required String prestataireId,
    required int periodDays,
    required int caPeriodCents,
    required int caPreviousPeriodCents,
    required int bookingsPending,
    required int bookingsConfirmed,
    required int bookingsDone,
    required int bookingsCancelled,
    required int bookingsTotal,
    required double occupancyPercent,
    required int capacitySlots,
    required int bookedSlots,
    required List<double> weekdayHeatmap,
    int? busiestWeekday,
    @JsonKey(name: 'weekly_revenue_3m')
    @Default([])
    List<StatsWeeklyRevenue> weeklyRevenue3m,
    @Default([]) List<StatsChartPoint> chart,
  }) = _StatsPrestataire;

  factory StatsPrestataire.fromJson(Map<String, dynamic> json) =>
      _$StatsPrestataireFromJson(json);

  static const empty = StatsPrestataire(
    prestataireId: '',
    periodDays: 30,
    caPeriodCents: 0,
    caPreviousPeriodCents: 0,
    bookingsPending: 0,
    bookingsConfirmed: 0,
    bookingsDone: 0,
    bookingsCancelled: 0,
    bookingsTotal: 0,
    occupancyPercent: 0,
    capacitySlots: 0,
    bookedSlots: 0,
    weekdayHeatmap: [0, 0, 0, 0, 0, 0, 0],
  );
}

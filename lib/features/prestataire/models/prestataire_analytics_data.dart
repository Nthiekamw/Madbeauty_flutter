/// Intensité par jour de la semaine (index = [DateTime.monday] … [DateTime.sunday]).
typedef WeekdayHeatmap = List<double>;

/// Données agrégées pour le tableau de bord analytique prestataire.
class PrestataireAnalyticsData {
  const PrestataireAnalyticsData({
    required this.periodRevenueEur,
    required this.previousPeriodRevenueEur,
    required this.revenueChangePercent,
    required this.chartRevenueEur,
    required this.chartLabels,
    required this.occupancyPercent,
    required this.weekdayHeatmap,
    required this.weekdayLabels,
    required this.busiestWeekday,
    required this.periodTotalRequests,
    required this.periodCancelled,
    required this.periodConfirmed,
    required this.periodCompleted,
    required this.conversionPercent,
  });

  final double periodRevenueEur;
  final double previousPeriodRevenueEur;
  final double? revenueChangePercent;
  final List<double> chartRevenueEur;
  final List<String> chartLabels;
  /// % de créneaux remplis sur la période filtrée.
  final double occupancyPercent;
  final WeekdayHeatmap weekdayHeatmap;
  final List<String> weekdayLabels;
  /// [DateTime.monday] … [DateTime.sunday], ou `null` si aucune réservation.
  final int? busiestWeekday;
  final int periodTotalRequests;
  final int periodCancelled;
  final int periodConfirmed;
  final int periodCompleted;
  final double? conversionPercent;

  static const empty = PrestataireAnalyticsData(
    periodRevenueEur: 0,
    previousPeriodRevenueEur: 0,
    revenueChangePercent: null,
    chartRevenueEur: [],
    chartLabels: [],
    occupancyPercent: 0,
    weekdayHeatmap: [0, 0, 0, 0, 0, 0, 0],
    weekdayLabels: ['L', 'M', 'M', 'J', 'V', 'S', 'D'],
    busiestWeekday: null,
    periodTotalRequests: 0,
    periodCancelled: 0,
    periodConfirmed: 0,
    periodCompleted: 0,
    conversionPercent: null,
  );
}

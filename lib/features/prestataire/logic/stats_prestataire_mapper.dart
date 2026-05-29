import '../../../core/models/domain/stats/stats_prestataire.dart';
import '../models/prestataire_analytics_data.dart';

extension StatsPrestataireMapper on StatsPrestataire {
  static const _weekdayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  PrestataireAnalyticsData toAnalyticsData() {
    final periodEur = caPeriodCents / 100;
    final previousEur = caPreviousPeriodCents / 100;

    return PrestataireAnalyticsData(
      periodRevenueEur: periodEur,
      previousPeriodRevenueEur: previousEur,
      revenueChangePercent: _percentChange(previousEur, periodEur),
      chartRevenueEur: chart.map((p) => p.revenueCents / 100).toList(),
      chartLabels: chart.map((p) => p.label).toList(),
      occupancyPercent: occupancyPercent,
      weekdayHeatmap: weekdayHeatmap,
      weekdayLabels: _weekdayLabels,
      busiestWeekday: busiestWeekday,
      periodTotalRequests: bookingsTotal,
      periodCancelled: bookingsCancelled,
      periodConfirmed: bookingsConfirmed,
      periodCompleted: bookingsDone,
      conversionPercent: _conversionRate(
        confirmed: bookingsConfirmed,
        total: bookingsTotal,
        cancelled: bookingsCancelled,
      ),
    );
  }

  static double? _percentChange(double previous, double current) {
    if (previous <= 0) return current > 0 ? 100 : null;
    return ((current - previous) / previous) * 100;
  }

  static double? _conversionRate({
    required int confirmed,
    required int total,
    required int cancelled,
  }) {
    final denominator = total - cancelled;
    if (denominator <= 0) return null;
    return (confirmed / denominator) * 100;
  }
}

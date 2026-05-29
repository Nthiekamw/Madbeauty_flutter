import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/models/domain/stats/stats_prestataire.dart';
import 'package:madbeauty/features/prestataire/logic/stats_prestataire_mapper.dart';

/// Réponse type `get_prestataire_stats` (snake_case).
const _sampleRpcJson = {
  'prestataire_id': '11111111-1111-1111-1111-111111111111',
  'period_days': 30,
  'ca_period_cents': 12500,
  'ca_previous_period_cents': 10000,
  'bookings_pending': 2,
  'bookings_confirmed': 5,
  'bookings_done': 3,
  'bookings_cancelled': 1,
  'bookings_total': 11,
  'occupancy_percent': 42.5,
  'capacity_slots': 80,
  'booked_slots': 34,
  'weekday_heatmap': [0.25, 0.5, 1.0, 0.75, 0.5, 0.25, 0.0],
  'busiest_weekday': 3,
  'weekly_revenue_3m': [
    {
      'week_start': '2026-05-05',
      'label': 'S1',
      'revenue_cents': 5000,
    },
    {
      'week_start': '2026-05-12',
      'label': 'S2',
      'revenue_cents': 7500,
    },
  ],
  'chart': [
    {'label': 'S1', 'revenue_cents': 4000},
    {'label': 'S2', 'revenue_cents': 8500},
  ],
};

void main() {
  group('StatsPrestataire', () {
    test('fromJson parse la réponse RPC', () {
      final stats = StatsPrestataire.fromJson(_sampleRpcJson);

      expect(stats.prestataireId, _sampleRpcJson['prestataire_id']);
      expect(stats.caPeriodCents, 12500);
      expect(stats.caPreviousPeriodCents, 10000);
      expect(stats.bookingsPending, 2);
      expect(stats.bookingsConfirmed, 5);
      expect(stats.bookingsDone, 3);
      expect(stats.bookingsCancelled, 1);
      expect(stats.occupancyPercent, 42.5);
      expect(stats.weekdayHeatmap, hasLength(7));
      expect(stats.busiestWeekday, DateTime.wednesday);
      expect(stats.weeklyRevenue3m, hasLength(2));
      expect(stats.chart.first.revenueCents, 4000);
    });

    test('toAnalyticsData calcule CA, conversion et graphique', () {
      final data = StatsPrestataire.fromJson(_sampleRpcJson).toAnalyticsData();

      expect(data.periodRevenueEur, 125);
      expect(data.previousPeriodRevenueEur, 100);
      expect(data.revenueChangePercent, closeTo(25, 0.01));
      expect(data.chartRevenueEur, [40, 85]);
      expect(data.chartLabels, ['S1', 'S2']);
      expect(data.occupancyPercent, 42.5);
      expect(data.busiestWeekday, DateTime.wednesday);
      expect(data.periodTotalRequests, 11);
      expect(data.periodCancelled, 1);
      expect(data.periodConfirmed, 5);
      expect(data.periodCompleted, 3);
      // 5 confirmées / (11 - 1 annulées) ≈ 50 %
      expect(data.conversionPercent, closeTo(50, 0.01));
    });

    test('conversion null si aucune demande hors annulations', () {
      final stats = StatsPrestataire.fromJson({
        ..._sampleRpcJson,
        'bookings_total': 1,
        'bookings_cancelled': 1,
        'bookings_confirmed': 0,
      });

      expect(stats.toAnalyticsData().conversionPercent, isNull);
    });
  });
}

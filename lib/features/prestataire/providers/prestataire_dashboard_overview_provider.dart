import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/domain/stats/stats_prestataire.dart';
import '../../../services/supabase/booking/booking_service_providers.dart';
import '../../../services/supabase/stats/stats_service_providers.dart';
import '../../booking/logic/client_reservation_ui_status.dart';
import '../models/prestataire_reservation_item.dart';
import 'current_prestataire_provider.dart';

/// Données agrégées pour la grille « Aperçu » du dashboard.
class PrestataireDashboardOverviewData {
  const PrestataireDashboardOverviewData({
    required this.todayAppointments,
    required this.todayVsYesterdayDelta,
    required this.clientsThisMonth,
    required this.clientsChangePercent,
    required this.monthRevenueEur,
    required this.monthRevenueChangePercent,
    required this.totalRevenueEur,
    required this.totalRevenueChangePercent,
  });

  final int todayAppointments;
  final int? todayVsYesterdayDelta;
  final int clientsThisMonth;
  final double? clientsChangePercent;
  final double monthRevenueEur;
  final double? monthRevenueChangePercent;
  final double totalRevenueEur;
  final double? totalRevenueChangePercent;

  static const empty = PrestataireDashboardOverviewData(
    todayAppointments: 0,
    todayVsYesterdayDelta: null,
    clientsThisMonth: 0,
    clientsChangePercent: null,
    monthRevenueEur: 0,
    monthRevenueChangePercent: null,
    totalRevenueEur: 0,
    totalRevenueChangePercent: null,
  );
}

final prestataireDashboardOverviewProvider =
    FutureProvider.autoDispose<PrestataireDashboardOverviewData>((ref) async {
  final presta = await ref.watch(currentPrestataireProvider.future);
  if (presta == null) return PrestataireDashboardOverviewData.empty;

  final statsService = ref.watch(statsServiceProvider);
  final bookingService = ref.watch(bookingServiceProvider);
  if (statsService == null) return PrestataireDashboardOverviewData.empty;

  final stats30 = await statsService.getStatsForDays(
    prestataireId: presta.id,
    periodDays: 30,
  );

  var todayCount = 0;
  var yesterdayCount = 0;
  var clientsThisMonth = 0;
  var clientsPrevMonth = 0;

  if (bookingService != null) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    final monthStart = DateTime(now.year, now.month, 1);
    final prevMonthStart = DateTime(
      now.month == 1 ? now.year - 1 : now.year,
      now.month == 1 ? 12 : now.month - 1,
      1,
    );
    final prevMonthEnd = monthStart;

    final items = await bookingService.listForCurrentPrestataire();
    final thisMonthClients = <String>{};
    final prevMonthClients = <String>{};

    for (final item in items) {
      if (!_countsForOverview(item)) continue;
      final dt = item.dateHeure.toLocal();
      final day = DateTime(dt.year, dt.month, dt.day);
      if (day == todayStart) todayCount++;
      if (day == yesterdayStart) yesterdayCount++;

      final clientKey = item.clientId ?? item.clientName;
      if (!dt.isBefore(monthStart)) {
        thisMonthClients.add(clientKey);
      } else if (!dt.isBefore(prevMonthStart) && dt.isBefore(prevMonthEnd)) {
        prevMonthClients.add(clientKey);
      }
    }
    clientsThisMonth = thisMonthClients.length;
    clientsPrevMonth = prevMonthClients.length;
  }

  final monthRevenue = stats30.caPeriodCents / 100;
  final monthRevenuePrev = stats30.caPreviousPeriodCents / 100;
  final totalRevenue = _totalRevenueFromStats(stats30);

  return PrestataireDashboardOverviewData(
    todayAppointments: todayCount,
    todayVsYesterdayDelta: todayCount - yesterdayCount,
    clientsThisMonth: clientsThisMonth,
    clientsChangePercent: _percentChange(
      clientsPrevMonth.toDouble(),
      clientsThisMonth.toDouble(),
    ),
    monthRevenueEur: monthRevenue,
    monthRevenueChangePercent: _percentChange(monthRevenuePrev, monthRevenue),
    totalRevenueEur: totalRevenue,
    totalRevenueChangePercent: _percentChange(monthRevenuePrev, totalRevenue),
  );
});

bool _countsForOverview(PrestataireReservationItem item) {
  final status = clientReservationUiStatusFromStatut(item.statut);
  return status == ClientReservationUiStatus.confirmed ||
      status == ClientReservationUiStatus.done;
}

double _totalRevenueFromStats(StatsPrestataire stats) {
  if (stats.weeklyRevenue3m.isEmpty) {
    return stats.caPeriodCents / 100;
  }
  final cents = stats.weeklyRevenue3m.fold<int>(
    0,
    (sum, week) => sum + week.revenueCents,
  );
  return cents / 100;
}

double? _percentChange(double previous, double current) {
  if (previous <= 0) return current > 0 ? 100 : null;
  return ((current - previous) / previous) * 100;
}

String formatOverviewCurrency(double value) {
  final formatter = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '€',
    decimalDigits: 0,
  );
  return formatter.format(value);
}

String formatOverviewTrend({
  required double? percent,
  int? delta,
  required String vsLabel,
}) {
  if (delta != null && delta != 0) {
    final sign = delta > 0 ? '+' : '';
    return '$sign$delta $vsLabel';
  }
  if (percent == null || percent == 0) return '';
  final sign = percent > 0 ? '+' : '';
  return '$sign${percent.round()}% $vsLabel';
}

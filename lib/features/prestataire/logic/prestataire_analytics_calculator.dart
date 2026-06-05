import '../../../core/models/domain/availability/horaire_plage.dart';
import '../../../services/supabase/disponibilite/disponibilite_dow.dart';
import '../models/prestataire_analytics_data.dart';
import '../models/prestataire_analytics_period.dart';
import '../models/prestataire_analytics_reservation.dart';

/// Agrégations CA, réservations, occupation (règles métier MadBeauty).
abstract final class PrestataireAnalyticsCalculator {
  PrestataireAnalyticsCalculator._();

  static const _slotStepMinutes = 30;
  static const _weekdayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  static PrestataireAnalyticsData compute({
    required List<PrestataireAnalyticsReservation> reservations,
    required List<HorairePlage> horaires,
    required PrestataireAnalyticsPeriod period,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final periodEnd = DateTime(clock.year, clock.month, clock.day + 1);
    final periodStart = periodEnd.subtract(Duration(days: period.days));
    final prevEnd = periodStart;
    final prevStart = prevEnd.subtract(Duration(days: period.days));

    final inPeriod = reservations
        .where((r) => _inRange(r.dateHeure, periodStart, periodEnd))
        .toList();
    final inPrevious = reservations
        .where((r) => _inRange(r.dateHeure, prevStart, prevEnd))
        .toList();

    final periodCa = _sumRevenue(inPeriod);
    final previousCa = _sumRevenue(inPrevious);
    final chart = _chartForPeriod(inPeriod, period, periodStart, periodEnd);
    final counts = _reservationCounts(inPeriod);
    final heatmap = _weekdayHeatmap(inPeriod);
    final busiest = _busiestWeekday(heatmap);

    return PrestataireAnalyticsData(
      periodRevenueEur: periodCa,
      previousPeriodRevenueEur: previousCa,
      revenueChangePercent: _percentChange(previousCa, periodCa),
      chartRevenueEur: chart.$1,
      chartLabels: chart.$2,
      occupancyPercent: _occupancyPercent(
        reservations: inPeriod,
        horaires: horaires,
        rangeStart: periodStart,
        rangeEnd: periodEnd.subtract(const Duration(days: 1)),
      ),
      weekdayHeatmap: heatmap,
      weekdayLabels: _weekdayLabels,
      busiestWeekday: busiest,
      periodTotalRequests: counts.$2,
      periodCancelled: counts.$1,
      periodConfirmed: counts.$3,
      periodCompleted: counts.$4,
      conversionPercent: _conversionRate(
        confirmed: counts.$3,
        total: counts.$2,
        cancelled: counts.$1,
      ),
    );
  }

  static bool _inRange(DateTime dt, DateTime start, DateTime end) {
    final local = dt.toLocal();
    return !local.isBefore(start) && local.isBefore(end);
  }

  static String _normalizeStatut(String raw) {
    return raw.trim().toLowerCase().replaceAll('é', 'e');
  }

  static bool _isActiveBooking(String statut) {
    return const {
      'en_attente',
      'pending',
      'confirmee',
      'confirmed',
      'terminee',
      'completed',
    }.contains(_normalizeStatut(statut));
  }

  static double _sumRevenue(List<PrestataireAnalyticsReservation> rows) {
    var sum = 0.0;
    for (final r in rows) {
      sum += _revenueEur(r);
    }
    return sum;
  }

  static double _revenueEur(PrestataireAnalyticsReservation r) {
    final payment = r.paymentStatus?.trim().toLowerCase();
    if (payment == 'captured' && r.amountCents != null && r.amountCents! > 0) {
      return r.amountCents! / 100.0;
    }
    final s = _normalizeStatut(r.statut);
    if (s == 'confirmee' ||
        s == 'confirmed' ||
        s == 'terminee' ||
        s == 'completed') {
      return r.servicePriceEur;
    }
    return 0;
  }

  static (List<double>, List<String>) _chartForPeriod(
    List<PrestataireAnalyticsReservation> rows,
    PrestataireAnalyticsPeriod period,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    return switch (period) {
      PrestataireAnalyticsPeriod.days7 => _dailyChart(rows, periodEnd, 7),
      PrestataireAnalyticsPeriod.days30 => _weeklyChart(rows, periodStart, periodEnd),
      PrestataireAnalyticsPeriod.months3 => _monthlyChart(rows, periodEnd, 3),
    };
  }

  static (List<double>, List<String>) _dailyChart(
    List<PrestataireAnalyticsReservation> rows,
    DateTime periodEnd,
    int days,
  ) {
    final amounts = <double>[];
    final labels = <String>[];
    for (var i = days - 1; i >= 0; i--) {
      final dayStart = DateTime(
        periodEnd.year,
        periodEnd.month,
        periodEnd.day,
      ).subtract(Duration(days: i + 1));
      final dayEnd = dayStart.add(const Duration(days: 1));
      final slice = rows.where(
        (r) => !r.dateHeure.isBefore(dayStart) && r.dateHeure.isBefore(dayEnd),
      );
      amounts.add(_sumRevenue(slice.toList()));
      labels.add(_weekdayLabels[dayStart.weekday - 1]);
    }
    return (amounts, labels);
  }

  static (List<double>, List<String>) _weeklyChart(
    List<PrestataireAnalyticsReservation> rows,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    final amounts = <double>[];
    final labels = <String>[];
    var weekStart = periodStart;
    var index = 1;
    while (weekStart.isBefore(periodEnd) && index <= 5) {
      final weekEnd = weekStart.add(const Duration(days: 7));
      final end = weekEnd.isBefore(periodEnd) ? weekEnd : periodEnd;
      final slice = rows.where(
        (r) => !r.dateHeure.isBefore(weekStart) && r.dateHeure.isBefore(end),
      );
      amounts.add(_sumRevenue(slice.toList()));
      labels.add('S$index');
      index++;
      weekStart = weekEnd;
    }
    return (amounts, labels);
  }

  static (List<double>, List<String>) _monthlyChart(
    List<PrestataireAnalyticsReservation> rows,
    DateTime periodEnd,
    int months,
  ) {
    final amounts = <double>[];
    final labels = <String>[];
    for (var i = months - 1; i >= 0; i--) {
      final monthStart = DateTime(periodEnd.year, periodEnd.month - i);
      final monthEnd = DateTime(periodEnd.year, periodEnd.month - i + 1);
      final slice = rows.where(
        (r) => !r.dateHeure.isBefore(monthStart) && r.dateHeure.isBefore(monthEnd),
      );
      amounts.add(_sumRevenue(slice.toList()));
      labels.add('M${monthStart.month}');
    }
    return (amounts, labels);
  }

  static (int, int, int, int) _reservationCounts(
    List<PrestataireAnalyticsReservation> rows,
  ) {
    var cancelled = 0;
    var confirmed = 0;
    var completed = 0;
    for (final r in rows) {
      final s = _normalizeStatut(r.statut);
      if (s == 'annulee' || s == 'cancelled' || s == 'canceled') {
        cancelled++;
      } else if (s == 'confirmee' || s == 'confirmed') {
        confirmed++;
      } else if (s == 'terminee' || s == 'completed') {
        completed++;
      }
    }
    return (cancelled, rows.length, confirmed, completed);
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

  static double? _percentChange(double previous, double current) {
    if (previous <= 0) return current > 0 ? 100 : null;
    return ((current - previous) / previous) * 100;
  }

  /// Réservations actives par jour de semaine (lun—dim).
  static List<double> _weekdayHeatmap(
    List<PrestataireAnalyticsReservation> rows,
  ) {
    final counts = List<double>.filled(7, 0);
    for (final r in rows) {
      if (!_isActiveBooking(r.statut)) continue;
      final w = r.dateHeure.weekday;
      counts[w - 1]++;
    }
    final max = counts.reduce((a, b) => a > b ? a : b);
    if (max <= 0) return List<double>.filled(7, 0);
    return counts.map((c) => c / max).toList();
  }

  static int? _busiestWeekday(List<double> heatmap) {
    var best = -1.0;
    int? weekday;
    for (var i = 0; i < heatmap.length; i++) {
      if (heatmap[i] > best) {
        best = heatmap[i];
        weekday = i + 1;
      }
    }
    return best <= 0 ? null : weekday;
  }

  static double _occupancyPercent({
    required List<PrestataireAnalyticsReservation> reservations,
    required List<HorairePlage> horaires,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) {
    if (horaires.isEmpty) return 0;

    var capacitySlots = 0;
    var bookedSlots = 0;

    var day = DateTime(rangeStart.year, rangeStart.month, rangeStart.day);
    final lastDay = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day);

    while (!day.isAfter(lastDay)) {
      final pgDow = DisponibiliteDow.fromDartWeekday(day.weekday);
      for (final plage in horaires.where((p) => p.jourSemaine == pgDow)) {
        capacitySlots += _slotsInPlage(plage) * plage.capaciteSimultanee;
      }

      final dayStart = day;
      final dayEnd = day.add(const Duration(days: 1));
      for (final r in reservations) {
        if (!_isActiveBooking(r.statut)) continue;
        if (r.dateHeure.isBefore(dayStart) || !r.dateHeure.isBefore(dayEnd)) {
          continue;
        }
        bookedSlots++;
      }
      day = day.add(const Duration(days: 1));
    }

    if (capacitySlots <= 0) return 0;
    return ((bookedSlots / capacitySlots) * 100).clamp(0, 100);
  }

  static int _slotsInPlage(HorairePlage plage) {
    var cursor = plage.heureDebut.hour * 60 + plage.heureDebut.minute;
    final endMin = plage.heureFin.hour * 60 + plage.heureFin.minute;
    var count = 0;
    while (cursor + _slotStepMinutes <= endMin) {
      count++;
      cursor += _slotStepMinutes;
    }
    return count;
  }

  static String weekdayName(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Lundi',
      DateTime.tuesday => 'Mardi',
      DateTime.wednesday => 'Mercredi',
      DateTime.thursday => 'Jeudi',
      DateTime.friday => 'Vendredi',
      DateTime.saturday => 'Samedi',
      DateTime.sunday => 'Dimanche',
      _ => '',
    };
  }
}


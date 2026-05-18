import '../../booking/logic/client_reservation_ui_status.dart';
import '../models/prestataire_dashboard_data.dart';
import '../models/prestataire_reservation_item.dart';

bool _isSameDay(DateTime a, DateTime b) {
  final al = a.toLocal();
  final bl = b.toLocal();
  return al.year == bl.year && al.month == bl.month && al.day == bl.day;
}

bool _isWithinWeek(DateTime date, DateTime now) {
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 7));
  final local = date.toLocal();
  return !local.isBefore(start) && local.isBefore(end);
}

PrestataireDashboardData splitPrestataireReservations(
  List<PrestataireReservationItem> items, {
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final pending = <PrestataireReservationItem>[];
  final today = <PrestataireReservationItem>[];
  final week = <PrestataireReservationItem>[];

  for (final item in items) {
    final status = clientReservationUiStatusFromStatut(item.statut);
    if (status == ClientReservationUiStatus.pending) {
      pending.add(item);
      continue;
    }
    if (status != ClientReservationUiStatus.confirmed) continue;

    if (_isSameDay(item.dateHeure, clock)) {
      today.add(item);
    } else if (_isWithinWeek(item.dateHeure, clock)) {
      week.add(item);
    }
  }

  return PrestataireDashboardData(
    pending: pending,
    todayConfirmed: today,
    weekConfirmed: week,
  );
}

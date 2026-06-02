import '../../booking/logic/client_reservation_ui_status.dart';
import '../models/prestataire_reservation_item.dart';

enum PrestataireAgendaTab { upcoming, past, cancelled }

List<PrestataireReservationItem> filterPrestataireAgendaReservations(
  List<PrestataireReservationItem> all,
  PrestataireAgendaTab tab,
) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);

  bool isCancelled(PrestataireReservationItem r) =>
      clientReservationUiStatusFromStatut(r.statut) ==
      ClientReservationUiStatus.cancelled;

  bool isDone(PrestataireReservationItem r) =>
      clientReservationUiStatusFromStatut(r.statut) ==
      ClientReservationUiStatus.done;

  final filtered = all.where((r) {
    final status = clientReservationUiStatusFromStatut(r.statut);
    switch (tab) {
      case PrestataireAgendaTab.cancelled:
        return status == ClientReservationUiStatus.cancelled;
      case PrestataireAgendaTab.past:
        if (isCancelled(r)) return false;
        return isDone(r) ||
            r.dateHeure.isBefore(todayStart);
      case PrestataireAgendaTab.upcoming:
        if (isCancelled(r) || isDone(r)) return false;
        final day = DateTime(
          r.dateHeure.year,
          r.dateHeure.month,
          r.dateHeure.day,
        );
        return !day.isBefore(todayStart);
    }
  }).toList();

  filtered.sort((a, b) {
    final cmp = tab == PrestataireAgendaTab.past
        ? b.dateHeure.compareTo(a.dateHeure)
        : a.dateHeure.compareTo(b.dateHeure);
    return cmp;
  });
  return filtered;
}

/// Regroupe par jour (clé = minuit local).
Map<DateTime, List<PrestataireReservationItem>> groupReservationsByDay(
  List<PrestataireReservationItem> items,
) {
  final map = <DateTime, List<PrestataireReservationItem>>{};
  for (final item in items) {
    final key = DateTime(
      item.dateHeure.year,
      item.dateHeure.month,
      item.dateHeure.day,
    );
    map.putIfAbsent(key, () => []).add(item);
  }
  for (final list in map.values) {
    list.sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
  }
  return map;
}

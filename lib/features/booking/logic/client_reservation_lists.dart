import '../logic/client_reservation_ui_status.dart';
import '../models/client_reservation_summary.dart';

List<ClientReservationSummary> clientUpcomingReservations(
  List<ClientReservationSummary> all,
) {
  final now = DateTime.now();
  return all
      .where((r) {
        final ui = clientReservationUiStatusFromStatut(r.statut);
        if (ui == ClientReservationUiStatus.cancelled) return false;
        if (ui == ClientReservationUiStatus.done) return false;
        if (ui == ClientReservationUiStatus.pending ||
            ui == ClientReservationUiStatus.syncPending ||
            ui == ClientReservationUiStatus.confirmed) {
          return true;
        }
        return !r.dateHeure.isBefore(now);
      })
      .toList()
    ..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
}

List<ClientReservationSummary> clientPastReservations(
  List<ClientReservationSummary> all,
) {
  final now = DateTime.now();
  return all
      .where((r) {
        final ui = clientReservationUiStatusFromStatut(r.statut);
        if (ui == ClientReservationUiStatus.cancelled) return true;
        if (ui == ClientReservationUiStatus.done) return true;
        if (ui == ClientReservationUiStatus.pending ||
            ui == ClientReservationUiStatus.syncPending ||
            ui == ClientReservationUiStatus.confirmed) {
          return false;
        }
        return r.dateHeure.isBefore(now);
      })
      .toList()
    ..sort((a, b) => b.dateHeure.compareTo(a.dateHeure));
}

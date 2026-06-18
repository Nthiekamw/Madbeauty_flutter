import '../logic/client_reservation_ui_status.dart';
import '../models/client_reservation_summary.dart';

bool clientReservationIsUpcoming(
  ClientReservationSummary reservation, {
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final ui = clientReservationUiStatusFromStatut(reservation.statut);
  if (ui == ClientReservationUiStatus.cancelled) return false;
  if (ui == ClientReservationUiStatus.done) return false;
  return reservation.dateHeure.isAfter(clock);
}

bool clientReservationIsPast(
  ClientReservationSummary reservation, {
  DateTime? now,
}) {
  final ui = clientReservationUiStatusFromStatut(reservation.statut);
  if (ui == ClientReservationUiStatus.cancelled) return true;
  if (ui == ClientReservationUiStatus.done) return true;
  final clock = now ?? DateTime.now();
  return !reservation.dateHeure.isAfter(clock);
}

List<ClientReservationSummary> clientUpcomingReservations(
  List<ClientReservationSummary> all, {
  DateTime? now,
}) {
  return all
      .where((r) => clientReservationIsUpcoming(r, now: now))
      .toList()
    ..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
}

List<ClientReservationSummary> clientPastReservations(
  List<ClientReservationSummary> all, {
  DateTime? now,
}) {
  return all
      .where((r) => clientReservationIsPast(r, now: now))
      .toList()
    ..sort((a, b) => b.dateHeure.compareTo(a.dateHeure));
}


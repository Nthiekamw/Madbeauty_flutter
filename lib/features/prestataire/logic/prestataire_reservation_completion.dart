import '../../booking/logic/client_reservation_ui_status.dart';
import '../models/prestataire_reservation_item.dart';

const int kDefaultPrestataireReservationDurationMinutes = 60;

/// Fin estimée du créneau (début + durée du service).
DateTime prestataireReservationEndAt(
  PrestataireReservationItem item,
) {
  final minutes = item.durationMinutes <= 0
      ? kDefaultPrestataireReservationDurationMinutes
      : item.durationMinutes;
  return item.dateHeure.add(Duration(minutes: minutes));
}

/// Le prestataire peut clôturer une réservation confirmée une fois le créneau passé.
bool prestataireCanMarkReservationDone(
  PrestataireReservationItem item, {
  DateTime? now,
}) {
  final status = clientReservationUiStatusFromStatut(item.statut);
  if (status != ClientReservationUiStatus.confirmed) return false;
  final clock = now ?? DateTime.now();
  return !prestataireReservationEndAt(item).isAfter(clock);
}

/// Réservation confirmée dont le créneau est passé mais pas encore clôturée.
bool prestataireNeedsCompletionReminder(
  PrestataireReservationItem item, {
  DateTime? now,
}) {
  return prestataireCanMarkReservationDone(item, now: now);
}

List<PrestataireReservationItem> prestataireReservationsNeedingCompletion(
  Iterable<PrestataireReservationItem> items, {
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  return items
      .where((item) => prestataireNeedsCompletionReminder(item, now: clock))
      .toList()
    ..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
}

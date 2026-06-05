import '../../booking/logic/client_reservation_ui_status.dart';
import '../models/prestataire_reservation_item.dart';

/// Groupe client pour l'historique prestataire.
class PrestataireHistoryClientGroup {
  const PrestataireHistoryClientGroup({
    required this.clientKey,
    required this.clientName,
    required this.reservations,
  });

  final String clientKey;
  final String clientName;
  final List<PrestataireReservationItem> reservations;
}

bool isPrestataireHistoryReservation(PrestataireReservationItem item) {
  final status = clientReservationUiStatusFromStatut(item.statut);
  if (status == ClientReservationUiStatus.done ||
      status == ClientReservationUiStatus.cancelled) {
    return true;
  }
  return item.dateHeure.isBefore(DateTime.now());
}

List<PrestataireHistoryClientGroup> groupPrestataireHistoryByClient(
  List<PrestataireReservationItem> all,
) {
  final history = all.where(isPrestataireHistoryReservation).toList()
    ..sort((a, b) => b.dateHeure.compareTo(a.dateHeure));

  final groups = <String, PrestataireHistoryClientGroup>{};
  for (final item in history) {
    final key = (item.clientId?.trim().isNotEmpty == true)
        ? item.clientId!.trim()
        : item.clientName.trim();
    final existing = groups[key];
    if (existing == null) {
      groups[key] = PrestataireHistoryClientGroup(
        clientKey: key,
        clientName: item.clientName,
        reservations: [item],
      );
    } else {
      groups[key] = PrestataireHistoryClientGroup(
        clientKey: key,
        clientName: existing.clientName,
        reservations: [...existing.reservations, item],
      );
    }
  }

  final list = groups.values.map((group) {
    final sorted = [...group.reservations]
      ..sort((a, b) => b.dateHeure.compareTo(a.dateHeure));
    return PrestataireHistoryClientGroup(
      clientKey: group.clientKey,
      clientName: group.clientName,
      reservations: sorted,
    );
  }).toList()
    ..sort(
      (a, b) => b.reservations.first.dateHeure.compareTo(
        a.reservations.first.dateHeure,
      ),
    );
  return list;
}


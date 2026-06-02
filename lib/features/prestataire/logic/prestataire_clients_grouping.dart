import '../../booking/logic/booking_formatters.dart';
import '../../booking/logic/client_reservation_ui_status.dart';
import '../models/prestataire_reservation_item.dart';

/// Fiche client agrégée pour l’onglet Clients.
class PrestataireClientSummary {
  const PrestataireClientSummary({
    required this.clientKey,
    required this.clientName,
    required this.reservations,
    required this.lastVisit,
    required this.lastServiceName,
  });

  final String clientKey;
  final String clientName;
  final List<PrestataireReservationItem> reservations;
  final DateTime lastVisit;
  final String lastServiceName;

  int get bookingCount => reservations.length;
  bool get isLoyal => bookingCount >= 3;
}

List<PrestataireClientSummary> listPrestataireClientSummaries(
  List<PrestataireReservationItem> all,
) {
  final byKey = <String, List<PrestataireReservationItem>>{};

  for (final item in all) {
    if (clientReservationUiStatusFromStatut(item.statut) ==
        ClientReservationUiStatus.cancelled) {
      continue;
    }
    final key = (item.clientId?.trim().isNotEmpty == true)
        ? item.clientId!.trim()
        : item.clientName.trim();
    if (key.isEmpty) continue;
    byKey.putIfAbsent(key, () => []).add(item);
  }

  final summaries = <PrestataireClientSummary>[];
  for (final entry in byKey.entries) {
    final sorted = [...entry.value]
      ..sort((a, b) => b.dateHeure.compareTo(a.dateHeure));
    final latest = sorted.first;
    summaries.add(
      PrestataireClientSummary(
        clientKey: entry.key,
        clientName: latest.clientName,
        reservations: sorted,
        lastVisit: latest.dateHeure,
        lastServiceName: latest.serviceName,
      ),
    );
  }

  summaries.sort((a, b) => b.lastVisit.compareTo(a.lastVisit));
  return summaries;
}

String formatClientLastVisit(DateTime date) => formatBookingDate(date);

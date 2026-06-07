import 'package:madbeauty/core/logic/booking/client_reservation_ui_status.dart';

/// Le chat est ouvert une fois la réservation acceptée (ou terminée).
bool reservationStatutAllowsChat(String rawStatut) {
  return clientReservationCanMessage(
    clientReservationUiStatusFromStatut(rawStatut),
  );
}

bool clientReservationCanMessage(ClientReservationUiStatus status) {
  return status == ClientReservationUiStatus.confirmed ||
      status == ClientReservationUiStatus.done;
}

bool reservationStatutIsPending(String rawStatut) {
  final status = clientReservationUiStatusFromStatut(rawStatut);
  return status == ClientReservationUiStatus.pending ||
      status == ClientReservationUiStatus.syncPending;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/models/domain/booking/client_reservation_summary.dart';
import '../../features/booking/providers/booking_session_providers.dart';
import 'booking_local_reminders.dart';

typedef BookingReminderItem = ({
  String id,
  DateTime dateHeure,
  String title,
  String statut,
});

BookingReminderItem reminderItemFromSummary(ClientReservationSummary r) {
  return (
    id: r.id,
    dateHeure: r.dateHeure,
    title: r.serviceName ?? DiscBk.unknownSvc,
    statut: r.statut,
  );
}

Future<void> syncClientBookingReminders(
  List<ClientReservationSummary> list,
) async {
  await BookingLocalReminders.instance.syncForReservations(
    list.map(reminderItemFromSummary).toList(),
  );
}

Future<void> syncClientBookingRemindersFromRef(Ref ref) async {
  try {
    final list = await ref.read(clientReservationsProvider.future);
    await syncClientBookingReminders(list);
  } catch (_) {
    // Réservations pas encore disponibles.
  }
}

Future<void> syncClientBookingRemindersForOne({
  required String id,
  required DateTime dateHeure,
  required String serviceName,
  required String statut,
}) async {
  await BookingLocalReminders.instance.syncForReservations([
    (id: id, dateHeure: dateHeure, title: serviceName, statut: statut),
  ]);
}

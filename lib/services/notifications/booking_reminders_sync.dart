import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/models/domain/booking/client_reservation_summary.dart';
import '../../core/models/domain/booking/prestataire_reservation_item.dart';
import '../../features/booking/providers/booking_session_providers.dart';
import '../../features/prestataire/providers/agenda/prestataire_agenda_provider.dart';
import 'booking_local_reminders.dart';
import 'booking_reminder_schedule.dart';

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

BookingReminderItem reminderItemFromPrestataire(PrestataireReservationItem r) {
  return (
    id: r.id,
    dateHeure: r.dateHeure,
    title: '${r.clientDisplayName} · ${r.serviceName}',
    statut: r.statut,
  );
}

Future<void> syncClientBookingReminders(
  List<ClientReservationSummary> list,
) async {
  await BookingLocalReminders.instance.syncForReservations(
    list.map(reminderItemFromSummary).toList(),
    audience: BookingReminderAudience.client,
  );
}

Future<void> syncPrestataireBookingReminders(
  List<PrestataireReservationItem> list,
) async {
  await BookingLocalReminders.instance.syncForReservations(
    list.map(reminderItemFromPrestataire).toList(),
    audience: BookingReminderAudience.prestataire,
  );
}

Future<void> syncClientBookingRemindersFromRef(Ref ref) async {
  await syncClientBookingRemindersWithLoader(
    () => ref.read(clientReservationsProvider.future),
  );
}

Future<void> syncPrestataireBookingRemindersFromRef(Ref ref) async {
  await syncPrestataireBookingRemindersWithLoader(
    () => ref.read(prestataireAgendaProvider.future),
  );
}

Future<void> syncAllBookingRemindersFromRef(Ref ref) async {
  await Future.wait([
    syncClientBookingRemindersFromRef(ref),
    syncPrestataireBookingRemindersFromRef(ref),
  ]);
}

Future<void> syncClientBookingRemindersWithLoader(
  Future<List<ClientReservationSummary>> Function() load,
) async {
  try {
    await syncClientBookingReminders(await load());
  } catch (_) {
    // Réservations pas encore disponibles.
  }
}

Future<void> syncPrestataireBookingRemindersWithLoader(
  Future<List<PrestataireReservationItem>> Function() load,
) async {
  try {
    await syncPrestataireBookingReminders(await load());
  } catch (_) {
    // Agenda pas encore disponible.
  }
}

Future<void> syncAllBookingRemindersWithLoader({
  required Future<List<ClientReservationSummary>> Function() loadClient,
  required Future<List<PrestataireReservationItem>> Function() loadPresta,
}) async {
  await Future.wait([
    syncClientBookingRemindersWithLoader(loadClient),
    syncPrestataireBookingRemindersWithLoader(loadPresta),
  ]);
}

Future<void> syncClientBookingRemindersForOne({
  required String id,
  required DateTime dateHeure,
  required String serviceName,
  required String statut,
}) async {
  await BookingLocalReminders.instance.syncForReservations(
    [
      (id: id, dateHeure: dateHeure, title: serviceName, statut: statut),
    ],
    audience: BookingReminderAudience.client,
  );
}

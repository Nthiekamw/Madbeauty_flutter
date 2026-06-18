import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/notifications/booking_reminders_sync.dart';
import '../../booking/providers/booking_session_providers.dart';
import '../../prestataire/providers/agenda/prestataire_agenda_provider.dart';
import '../../prestataire/providers/dashboard/prestataire_dashboard_provider.dart';

/// Invalide les caches réservations client + prestataire après replay offline.
void invalidateBookingCachesAfterOfflineSync(Ref ref) {
  invalidateClientReservationsFromRef(ref);
  ref.invalidate(prestataireAgendaProvider);
  ref.invalidate(prestataireDashboardProvider);
  ref.invalidate(bookingsPrestataireProvider);
  unawaited(syncAllBookingRemindersFromRef(ref));
}

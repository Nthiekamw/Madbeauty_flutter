import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/booking/booking_service_providers.dart';
import 'prestataire_agenda_provider.dart';
import 'prestataire_dashboard_provider.dart';

void invalidatePrestataireBookings(WidgetRef ref) {
  ref.invalidate(prestataireAgendaProvider);
  ref.invalidate(prestataireDashboardProvider);
  ref.invalidate(bookingsPrestataireProvider);
  // Mise à jour « Mes réservations » (client) après acceptation / refus / terminé.
  invalidateClientReservations(ref);
}

void invalidatePrestataireDashboard(WidgetRef ref) {
  invalidatePrestataireBookings(ref);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/supabase/booking/booking_service_providers.dart';
import '../profile/current_prestataire_provider.dart';
import '../agenda/prestataire_agenda_provider.dart';
import '../analytics/prestataire_analytics_provider.dart';
import '../dashboard/prestataire_dashboard_provider.dart';
import '../analytics/stats_provider.dart';

void invalidatePrestataireBookings(WidgetRef ref) {
  ref.invalidate(prestataireAgendaProvider);
  ref.invalidate(prestataireAnalyticsProvider);
  final presta = switch (ref.read(currentPrestataireProvider)) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (presta != null) {
    invalidatePrestataireStats(ref, presta.id);
  }
  ref.invalidate(prestataireDashboardProvider);
  ref.invalidate(bookingsPrestataireProvider);
  // Mise à jour « Mes réservations » (client) après acceptation / refus / terminé.
  invalidateClientReservations(ref);
}

void invalidatePrestataireDashboard(WidgetRef ref) {
  invalidatePrestataireBookings(ref);
}


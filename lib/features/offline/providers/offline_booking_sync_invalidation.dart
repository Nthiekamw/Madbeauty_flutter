import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/booking/booking_service_providers.dart';
import '../../prestataire/providers/prestataire_agenda_provider.dart';
import '../../prestataire/providers/prestataire_dashboard_provider.dart';

/// Invalide les caches réservations client + prestataire après replay offline.
void invalidateBookingCachesAfterOfflineSync(Ref ref) {
  invalidateClientReservationsFromRef(ref);
  ref.invalidate(prestataireAgendaProvider);
  ref.invalidate(prestataireDashboardProvider);
  ref.invalidate(bookingsPrestataireProvider);
}

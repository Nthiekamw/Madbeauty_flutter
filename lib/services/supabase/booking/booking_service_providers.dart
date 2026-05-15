import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/domain/booking/reservation.dart';
import '../../../features/booking/models/client_reservation_summary.dart';
import '../../../features/prestataire/providers/current_prestataire_provider.dart';
import '../profile/client_profile_providers.dart';
import '../profile/profile_providers.dart';
import '../supabase_service.dart';
import 'booking_reservation_providers.dart';
import 'booking_service.dart';

final bookingServiceProvider = Provider<BookingService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  final slots = ref.watch(bookingReservationServiceProvider);
  if (slots == null) return null;
  return BookingService(
    SupabaseService.client,
    slots,
    ref.watch(profileServiceProvider),
  );
});

/// Liste des réservations (`Reservation`) du client connecté.
final bookingsClientProvider = FutureProvider<List<Booking>>((ref) async {
  final svc = ref.watch(bookingServiceProvider);
  final client = await ref.watch(currentClientProfileProvider.future);
  if (svc == null || client == null) return const [];
  return svc.getByClient(client.id);
});

/// Liste des réservations du prestataire connecté (`prestataire_profiles.id`).
final bookingsPrestataireProvider = FutureProvider<List<Booking>>((ref) async {
  final svc = ref.watch(bookingServiceProvider);
  final presta = await ref.watch(currentPrestataireProvider.future);
  if (svc == null || presta == null) return const [];
  return svc.getByPrestataire(presta.id);
});

/// Détail réservation accessible au client ou prestataire participant ([RLS]).
final bookingDetailProvider = FutureProvider.autoDispose.family<
  Booking?,
  String
>((ref, id) async {
  final svc = ref.watch(bookingServiceProvider);
  if (svc == null) return null;
  return svc.getById(id);
});

/// Liste des réservations client — conservée tant que le shell est monté.
///
/// Utilise encore un sous-ensemble pour les cartes (« résumés » enrichis UI).
final clientReservationsProvider =
    FutureProvider<List<ClientReservationSummary>>((ref) async {
      final service = ref.watch(bookingServiceProvider);
      if (service == null) return const [];
      return service.listForCurrentClient();
    });

/// Nombre de réservations « en attente » pour le badge de l’onglet Réservations.
final clientPendingReservationsCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(bookingServiceProvider);
  if (service == null) return 0;
  return service.countPendingForCurrentClient();
});

void invalidateClientReservations(WidgetRef ref) {
  ref.invalidate(clientReservationsProvider);
  ref.invalidate(clientPendingReservationsCountProvider);
  ref.invalidate(bookingsClientProvider);
  ref.invalidate(bookingsPrestataireProvider);
}

void invalidateBookingDetail(WidgetRef ref, String bookingId) {
  ref.invalidate(bookingDetailProvider(bookingId));
}

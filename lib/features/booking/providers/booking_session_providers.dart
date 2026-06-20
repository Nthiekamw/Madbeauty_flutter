import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/booking/client_reservation_summary.dart';
import '../../../core/models/domain/booking/reservation.dart';
import '../../../core/providers/offline_providers.dart';
import '../../../core/providers/offline_queue_providers.dart';
import '../../../features/auth/guest/guest_mode_provider.dart';
import '../../../features/auth/providers/auth_notifier.dart';
import '../../../features/prestataire/providers/profile/current_prestataire_provider.dart';
import '../../../services/offline/offline_cache_service.dart';
import '../../../services/offline/offline_sync_service.dart';
import '../../../services/offline/pending_offline_action.dart';
import '../../../services/supabase/booking/booking_service_core_providers.dart';
import '../../../services/supabase/profile/client_profile_providers.dart';

/// Liste des réservations (`Reservation`) du client connecté.
final bookingsClientProvider =
    FutureProvider.autoDispose<List<Booking>>((ref) async {
  final svc = ref.watch(bookingServiceProvider);
  final client = await ref.watch(currentClientProfileProvider.future);
  if (svc == null || client == null) return const [];
  return svc.getByClient(client.id);
});

/// Liste des réservations du prestataire connecté (`prestataire_profiles.id`).
final bookingsPrestataireProvider =
    FutureProvider.autoDispose<List<Booking>>((ref) async {
  final svc = ref.watch(bookingServiceProvider);
  final presta = await ref.watch(currentPrestataireProvider.future);
  if (svc == null || presta == null) return const [];
  return svc.getByPrestataire(presta.id);
});

/// Liste des réservations client (auto-dispose hors écran ; invalidée à chaque action).
final clientReservationsProvider =
    FutureProvider.autoDispose<List<ClientReservationSummary>>((ref) async {
      ref.watch(reservationsRefreshSignalProvider);
      if (ref.watch(isGuestBrowsingProvider)) return const [];

      final service = ref.watch(bookingServiceProvider);
      if (service == null) return const [];

      final loader = ref.read(offlineDataLoaderProvider);
      final cache = OfflineCacheService.instance;

      final remote = await loader.load<List<ClientReservationSummary>>(
        fallback: const [],
        readCache: cache.readClientReservations,
        writeCache: cache.saveClientReservations,
        fetchRemote: () => service.listForCurrentClient(),
      );

      final queue = ref.watch(offlineActionQueueProvider);
      return mergeClientReservationsWithQueue(remote, queue);
    });

/// Nombre de réservations « en attente » pour le badge de l'onglet Réservations.
final clientPendingReservationsCountProvider = FutureProvider<int>((ref) async {
  ref.watch(reservationsRefreshSignalProvider);
  final service = ref.watch(bookingServiceProvider);
  if (service == null) return 0;

  if (ref.watch(isGuestBrowsingProvider)) return 0;

  final user = switch (ref.watch(authNotifierProvider)) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (user == null) return 0;

  if (!ref.read(isOnlineProvider)) {
    final cached = OfflineCacheService.instance.readClientReservations();
    final queuePending = ref
        .watch(offlineActionQueueProvider)
        .where((a) => a.type == OfflineActionType.bookingCreate)
        .length;
    final cachedPending = cached
        .where((r) => r.statut == 'en_attente' || r.statut == 'pending')
        .length;
    return cachedPending + queuePending;
  }

  return service.countPendingForCurrentClient();
});

class _RefreshSignalNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state = state + 1;
}

final reservationsRefreshSignalProvider =
    NotifierProvider<_RefreshSignalNotifier, int>(_RefreshSignalNotifier.new);

void invalidateClientReservations(WidgetRef ref) {
  ref.invalidate(clientReservationsProvider);
  ref.invalidate(clientPendingReservationsCountProvider);
  ref.invalidate(bookingsClientProvider);
  ref.invalidate(bookingsPrestataireProvider);
  ref.read(reservationsRefreshSignalProvider.notifier).increment();
}

void invalidateClientReservationsFromRef(Ref ref) {
  ref.invalidate(clientReservationsProvider);
  ref.invalidate(clientPendingReservationsCountProvider);
  ref.invalidate(bookingsClientProvider);
  ref.invalidate(bookingsPrestataireProvider);
}

void invalidateBookingDetail(WidgetRef ref, String bookingId) {
  ref.invalidate(bookingDetailProvider(bookingId));
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/providers/offline_providers.dart';
import '../../../../services/offline/offline_cache_service.dart';
import '../../../../services/supabase/booking/booking_service_providers.dart';
import '../../../../services/supabase/supabase_service.dart';
import '../../models/prestataire_reservation_item.dart';
import '../profile/current_prestataire_provider.dart';
import '../dashboard/prestataire_dashboard_provider.dart';

/// Réservations prestataire avec écoute Realtime (`reservations`).
final prestataireAgendaProvider = AsyncNotifierProvider<
  PrestataireAgendaNotifier,
  List<PrestataireReservationItem>
>(PrestataireAgendaNotifier.new);

class PrestataireAgendaNotifier
    extends AsyncNotifier<List<PrestataireReservationItem>> {
  RealtimeChannel? _channel;

  @override
  Future<List<PrestataireReservationItem>> build() async {
    ref.onDispose(_unsubscribe);
    return _load();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<List<PrestataireReservationItem>> _load() async {
    _unsubscribe();
    if (!AppConfig.hasSupabase) return const [];

    final presta = await ref.watch(currentPrestataireProvider.future);
    if (presta == null) return const [];

    final service = ref.read(bookingServiceProvider);
    if (service == null) return const [];

    final loader = ref.read(offlineDataLoaderProvider);
    final cache = OfflineCacheService.instance;

    final items = await loader.load<List<PrestataireReservationItem>>(
      fallback: const <PrestataireReservationItem>[],
      readCache: cache.readPrestataireAgenda,
      writeCache: cache.savePrestataireAgenda,
      fetchRemote: () => service.listForCurrentPrestataire(),
    );

    if (ref.read(isOnlineProvider)) {
      _subscribe(presta.id);
    }
    return items;
  }

  void _subscribe(String prestataireId) {
    _channel = SupabaseService.client
        .channel('prestataire-reservations-$prestataireId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'reservations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'prestataire_id',
            value: prestataireId,
          ),
          callback: (_) => unawaited(_onRealtimeEvent()),
        )
        .subscribe();
  }

  Future<void> _onRealtimeEvent() async {
    final service = ref.read(bookingServiceProvider);
    if (service == null) return;
    try {
      final items = await service.listForCurrentPrestataire();
      state = AsyncData(items);
      ref.invalidate(prestataireDashboardProvider);
    } catch (_) {
      // Garde la liste affichée ; un pull-to-refresh permet de resynchroniser.
    }
  }

  void _unsubscribe() {
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      unawaited(SupabaseService.client.removeChannel(channel));
    }
  }
}


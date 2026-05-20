import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/offline_providers.dart';
import '../../../services/offline/offline_cache_service.dart';
import '../../../services/supabase/booking/booking_service_providers.dart';
import '../logic/prestataire_dashboard_split.dart';
import '../models/prestataire_dashboard_data.dart';

final prestataireDashboardProvider =
    FutureProvider.autoDispose<PrestataireDashboardData>((ref) async {
      const empty = PrestataireDashboardData(
        pending: [],
        todayConfirmed: [],
        weekConfirmed: [],
      );

      final service = ref.watch(bookingServiceProvider);
      if (service == null) return empty;

      final loader = ref.read(offlineDataLoaderProvider);
      final cache = OfflineCacheService.instance;

      return loader.load(
        fallback: empty,
        readCache: cache.readPrestataireDashboard,
        writeCache: cache.savePrestataireDashboard,
        fetchRemote: () async {
          final items = await service.listForCurrentPrestataire();
          return splitPrestataireReservations(items);
        },
      );
    });

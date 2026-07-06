import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/offline_providers.dart';
import '../../../../services/offline/offline_cache_service.dart';
import '../../../../services/supabase/booking/booking_service_providers.dart';
import '../../../auth/providers/auth_notifier.dart';
import '../../logic/prestataire_dashboard_split.dart';
import '../../models/prestataire_dashboard_data.dart';

final prestataireDashboardProvider =
    FutureProvider.autoDispose<PrestataireDashboardData>((ref) async {
      const empty = PrestataireDashboardData(
        pending: [],
        todayConfirmed: [],
        weekConfirmed: [],
        needsCompletion: [],
      );

      final user = switch (ref.watch(authNotifierProvider)) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (user == null) return empty;

      final service = ref.watch(bookingServiceProvider);
      if (service == null) return empty;

      final loader = ref.read(offlineDataLoaderProvider);
      final cache = OfflineCacheService.instance;
      final userId = user.id;

      return loader.load(
        fallback: empty,
        readCache: () => cache.readPrestataireDashboard(userId),
        writeCache: (data) => cache.savePrestataireDashboard(userId, data),
        fetchRemote: () async {
          final items = await service.listForCurrentPrestataire();
          return splitPrestataireReservations(items);
        },
      );
    });


import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/user/prestataire_profile.dart';
import '../../../core/providers/offline_providers.dart';
import '../../../services/offline/offline_cache_service.dart';
import '../../../services/supabase/prestataire/catalog/prestataire_catalog_providers.dart';

/// Profils triés par [PrestataireProfile.noteMoyenne] (section « Mieux notés »).
final topRatedPrestatairesProvider =
    FutureProvider.autoDispose<List<PrestataireProfile>>((ref) async {
      final service = ref.watch(prestataireServiceProvider);
      if (service == null) return const [];

      final loader = ref.read(offlineDataLoaderProvider);
      final cache = OfflineCacheService.instance;

      final list = await loader.load<List<PrestataireProfile>>(
        fallback: const [],
        readCache: cache.readTopRatedPrestataires,
        writeCache: cache.saveTopRatedPrestataires,
        fetchRemote: () => service.getBestRated(),
      );
      return list.where((p) => p.noteMoyenne != null).toList();
    });


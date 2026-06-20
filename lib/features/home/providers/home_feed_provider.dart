import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../core/models/domain/user/prestataire_profile.dart';
import '../../../services/supabase/prestataire/catalog/prestataire_catalog_providers.dart';
import '../../../services/supabase/prestataire/catalog/prestataire_filters.dart';
import '../models/home_feed_selection.dart';

/// Filtre inspiration / recherche (sections proches & mieux notés).
final homeFeedSelectionProvider =
    NotifierProvider<HomeFeedSelectionNotifier, HomeFeedSelection?>(
      HomeFeedSelectionNotifier.new,
    );

class HomeFeedSelectionNotifier extends Notifier<HomeFeedSelection?> {
  @override
  HomeFeedSelection? build() => HomeFeedSelection.defaultInspiration;

  void setSearch(String raw) {
    final query = raw.trim();
    if (query.isEmpty) {
      state = HomeFeedSelection.defaultInspiration;
      return;
    }
    state = HomeFeedSelection(query: query, source: HomeFeedSource.search);
  }

  void setMainServiceFilter({
    PrestaMainService? mainService,
    bool allServices = false,
  }) {
    if (allServices) {
      state = HomeFeedSelection.defaultInspiration;
      return;
    }
    if (mainService == null) return;
    state = HomeFeedSelection(
      source: HomeFeedSource.inspiration,
      mainService: mainService,
      query: PrestataireServiceCatalog.label(mainService),
    );
  }

  void clear() => state = HomeFeedSelection.defaultInspiration;
}

/// Prestataires « Tendances cette semaine » (indépendant du filtre inspiration).
final homeTrendingPrestatairesProvider =
    FutureProvider.autoDispose<List<PrestataireProfile>>((ref) async {
      final service = ref.watch(prestataireServiceProvider);
      if (service == null) return const [];

      final entries = await service.getAll(
        filters: const PrestataireFilters(limit: 16),
      );
      return entries.map((e) => e.profile).toList();
    });

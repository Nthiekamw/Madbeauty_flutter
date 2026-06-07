import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../core/models/domain/user/prestataire_profile.dart';
import '../../../services/supabase/prestataire/catalog/prestataire_catalog_providers.dart';
import '../../../services/supabase/prestataire/catalog/prestataire_filters.dart';
import '../models/home_feed_selection.dart';

/// Thème ou requête affichée dans la zone résultats de l'accueil.
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

bool _matchesMainService(
  PrestataireCatalogEntry entry,
  PrestaMainService main,
) {
  final categoryIds = PrestataireServiceCatalog.specialties(main)
      .map((s) => s.categoryId)
      .whereType<String>()
      .toSet();
  final specialtyLabels = PrestataireServiceCatalog.specialties(main)
      .map((s) => s.label.toLowerCase())
      .toSet();
  final mainLabel = PrestataireServiceCatalog.label(main).toLowerCase();

  if (entry.specialtyCategoryIds.any(categoryIds.contains)) return true;
  for (final name in entry.specialtyNames) {
    final lower = name.toLowerCase();
    if (specialtyLabels.contains(lower)) return true;
    if (lower.contains(mainLabel)) return true;
  }
  return false;
}

/// Prestataires filtrés pour la zone résultats de l'accueil.
final homeFeedPrestatairesProvider =
    FutureProvider.autoDispose<List<PrestataireProfile>>((ref) async {
      final selection = ref.watch(homeFeedSelectionProvider);
      if (selection == null || !selection.showsFeedSection) {
        return const [];
      }

      final service = ref.watch(prestataireServiceProvider);
      if (service == null) return const [];

      final filters = selection.allServices
          ? const PrestataireFilters(limit: 16)
          : PrestataireFilters(
              query: selection.source == HomeFeedSource.search
                  ? selection.query
                  : null,
              limit: 16,
            );

      var entries = await service.getAll(filters: filters);

      if (selection.mainService != null) {
        final main = selection.mainService!;
        entries =
            entries.where((e) => _matchesMainService(e, main)).toList();
      }

      return entries.map((e) => e.profile).toList();
    });

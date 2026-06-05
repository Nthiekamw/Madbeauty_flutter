import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  HomeFeedSelection? build() => null;

  void setSearch(String raw) {
    final query = raw.trim();
    if (query.isEmpty) {
      state = null;
      return;
    }
    state = HomeFeedSelection(query: query, source: HomeFeedSource.search);
  }

  void setInspiration(String topic) {
    final query = topic.trim();
    if (query.isEmpty) return;
    state = HomeFeedSelection(
      query: query,
      source: HomeFeedSource.inspiration,
    );
  }

  void clear() => state = null;
}

/// Prestataires filtrés pour la zone résultats de l'accueil.
final homeFeedPrestatairesProvider =
    FutureProvider.autoDispose<List<PrestataireProfile>>((ref) async {
      final selection = ref.watch(homeFeedSelectionProvider);
      if (selection == null) return const [];

      final service = ref.watch(prestataireServiceProvider);
      if (service == null) return const [];

      final entries = await service.getAll(
        filters: PrestataireFilters(query: selection.query, limit: 16),
      );
      return entries.map((e) => e.profile).toList();
    });


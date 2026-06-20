import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../core/models/domain/user/prestataire_profile.dart';
import '../../../services/supabase/prestataire/catalog/prestataire_catalog_providers.dart';
import '../logic/home_feed_filter.dart';
import 'home_feed_provider.dart';
import 'nearby_prestataires_provider.dart';
import 'top_rated_prestataires_provider.dart';

Future<List<PrestataireCatalogEntry>> _entriesForProfiles(
  Ref ref,
  List<PrestataireProfile> profiles,
) async {
  if (profiles.isEmpty) return const [];
  final service = ref.read(prestataireServiceProvider);
  if (service == null) return const [];
  return service.getCatalogEntriesByIds(profiles.map((p) => p.id).toList());
}

final nearbyPrestataireEntriesProvider =
    FutureProvider.autoDispose<List<PrestataireCatalogEntry>>((ref) async {
  final selection = ref.watch(homeFeedSelectionProvider);
  final profiles = await ref.watch(nearbyPrestatairesProvider.future);
  final entries = await _entriesForProfiles(ref, profiles);
  return filterCatalogEntriesForHomeSelection(entries, selection);
});

final topRatedPrestataireEntriesProvider =
    FutureProvider.autoDispose<List<PrestataireCatalogEntry>>((ref) async {
  final selection = ref.watch(homeFeedSelectionProvider);
  final profiles = await ref.watch(topRatedPrestatairesProvider.future);
  final entries = await _entriesForProfiles(ref, profiles);
  return filterCatalogEntriesForHomeSelection(entries, selection);
});

final homeFeedPrestataireEntriesProvider =
    FutureProvider.autoDispose<List<PrestataireCatalogEntry>>((ref) async {
  final profiles = await ref.watch(homeTrendingPrestatairesProvider.future);
  return _entriesForProfiles(ref, profiles);
});

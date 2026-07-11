import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logic/prestataire/prestataire_map_visibility.dart';
import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../services/supabase/prestataire/catalog/prestataire_catalog_providers.dart';

/// Catalogue carte : tous les prestataires visibles avec coordonnées (profil complet).
final listingMapCatalogProvider =
    FutureProvider.autoDispose<List<PrestataireCatalogEntry>>((ref) async {
  final service = ref.watch(prestataireServiceProvider);
  if (service == null) return const [];
  final entries = await service.getMapCatalogEntries();
  return filterMapCatalogEntries(entries);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../services/supabase/prestataire/catalog/prestataire_catalog_providers.dart';
import 'client_favorite_prestataire_ids_provider.dart';

/// Entrées catalogue des prestataires favoris (ordre = date d'ajout).
final clientFavoriteCatalogProvider =
    FutureProvider.autoDispose<List<PrestataireCatalogEntry>>((ref) async {
  final ids = await ref.watch(clientFavoritePrestataireIdsProvider.future);
  if (ids.isEmpty) return [];

  final service = ref.watch(prestataireServiceProvider);
  if (service == null) return [];

  return service.getCatalogEntriesByIds(ids.toList());
});


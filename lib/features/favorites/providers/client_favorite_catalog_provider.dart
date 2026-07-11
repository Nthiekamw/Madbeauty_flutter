import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logic/market/prestataire_market_filter.dart';
import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../core/providers/market_country_provider.dart';
import '../../../services/supabase/prestataire/catalog/prestataire_catalog_providers.dart';
import 'client_favorite_prestataire_ids_provider.dart';

/// Entrées catalogue des prestataires favoris (ordre = date d'ajout).
final clientFavoriteCatalogProvider =
    FutureProvider.autoDispose<List<PrestataireCatalogEntry>>((ref) async {
  final marketCountry = ref.watch(marketCountryProvider);
  final ids = await ref.watch(clientFavoritePrestataireIdsProvider.future);
  if (ids.isEmpty) return [];

  final service = ref.watch(prestataireServiceProvider);
  if (service == null) return [];

  final entries = await service.getCatalogEntriesByIds(
    ids.toList(),
    pays: marketCountry,
  );
  return filterCatalogEntriesByMarket(entries, marketCountry);
});


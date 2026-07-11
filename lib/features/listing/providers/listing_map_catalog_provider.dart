import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logic/market/prestataire_market_filter.dart';
import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../core/providers/market_country_provider.dart';
import '../../../services/supabase/prestataire/catalog/prestataire_catalog_providers.dart';

/// Catalogue carte : prestataires visibles du marché actif avec coordonnées.
final listingMapCatalogProvider =
    FutureProvider.autoDispose<List<PrestataireCatalogEntry>>((ref) async {
      final marketCountry = ref.watch(marketCountryProvider);
      final service = ref.watch(prestataireServiceProvider);
      if (service == null) return const [];

      final entries = await service.getMapCatalogEntries(pays: marketCountry);
      return filterCatalogEntriesByMarket(entries, marketCountry);
    });

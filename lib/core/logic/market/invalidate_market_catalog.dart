import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madbeauty/features/home/logic/client_home_refresh.dart';
import 'package:madbeauty/features/home/providers/home_feed_provider.dart';
import 'package:madbeauty/features/listing/providers/listing_catalog_provider.dart';
import 'package:madbeauty/features/listing/providers/listing_map_catalog_provider.dart';

/// Recharge catalogue et accueil après changement de marché.
void invalidateMarketCatalog(WidgetRef ref) {
  invalidateClientHome(ref);
  ref.invalidate(listingMapCatalogProvider);
  ref.read(listingCatalogNotifierProvider.notifier).refresh();
}

/// Invalide les providers catalogue liés au marché (sans pull-to-refresh listing).
void invalidateMarketCatalogProviders(Ref ref) {
  ref.invalidate(homeTrendingPrestatairesProvider);
  ref.invalidate(listingMapCatalogProvider);
}

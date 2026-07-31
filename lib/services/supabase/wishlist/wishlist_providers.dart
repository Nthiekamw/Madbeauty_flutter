import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../profile/client_profile_providers.dart';
import '../supabase_service.dart';
import 'wishlist_service.dart';

final wishlistServiceProvider = Provider<WishlistService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return WishlistService(SupabaseService.client);
});

/// Entrées wishlist du client connecté (produits joints).
final clientWishlistEntriesProvider =
    FutureProvider.autoDispose<List<WishlistEntry>>((ref) async {
  final client = await ref.watch(currentClientProfileProvider.future);
  final service = ref.watch(wishlistServiceProvider);
  if (client == null || service == null) return const [];
  return service.listWithProducts(client.id);
});

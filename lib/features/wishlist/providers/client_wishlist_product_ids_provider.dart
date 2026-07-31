import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/profile/client_profile_providers.dart';
import '../../../services/supabase/wishlist/wishlist_providers.dart';
import '../../auth/providers/auth_notifier.dart';

/// Identifiants produits wishlist du client connecté (optimistic sync).
final clientWishlistProductIdsProvider =
    AsyncNotifierProvider<ClientWishlistProductIdsNotifier, Set<String>>(
  ClientWishlistProductIdsNotifier.new,
);

final isProduitInWishlistProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(clientWishlistProductIdsProvider).maybeWhen(
        data: (ids) => ids.contains(id),
        orElse: () => false,
      );
});

final clientWishlistCountProvider = Provider<int>((ref) {
  return ref.watch(clientWishlistProductIdsProvider).maybeWhen(
        data: (ids) => ids.length,
        orElse: () => 0,
      );
});

class ClientWishlistProductIdsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    ref.listen(authNotifierProvider, (prev, next) {
      final prevUid = switch (prev) {
        AsyncData(:final value) => value?.id,
        _ => null,
      };
      final nextUid = switch (next) {
        AsyncData(:final value) => value?.id,
        _ => null,
      };
      if (prevUid != nextUid) {
        ref.invalidateSelf();
      }
    });

    final user = switch (ref.watch(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (user == null) return {};

    final client = await ref.watch(currentClientProfileProvider.future);
    final service = ref.watch(wishlistServiceProvider);
    if (client == null || service == null) return {};

    return (await service.listProduitIds(client.id)).toSet();
  }

  /// Ajoute ou retire un produit (optimistic). [lastSeenPrice] requis à l’ajout.
  Future<void> toggle(
    String produitId, {
    required double lastSeenPrice,
  }) async {
    final client = await ref.read(currentClientProfileProvider.future);
    if (client == null) {
      throw StateError('Profil client requis pour la wishlist.');
    }

    final service = ref.read(wishlistServiceProvider);
    if (service == null) {
      throw StateError('Wishlist indisponible.');
    }

    final previous = switch (state) {
      AsyncData(:final value) => value,
      _ => await future,
    };
    final wasInWishlist = previous.contains(produitId);
    final optimistic = wasInWishlist
        ? (Set<String>.from(previous)..remove(produitId))
        : {...previous, produitId};

    state = AsyncData(optimistic);

    try {
      if (wasInWishlist) {
        await service.remove(clientId: client.id, produitId: produitId);
      } else {
        await service.add(
          clientId: client.id,
          produitId: produitId,
          lastSeenPrice: lastSeenPrice,
        );
      }
      ref.invalidate(clientWishlistEntriesProvider);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

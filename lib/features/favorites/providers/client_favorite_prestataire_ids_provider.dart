import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/storage/client_favorites_local_store.dart';
import '../../../services/supabase/favorites/favori_providers.dart';
import '../../../services/supabase/favorites/favori_service.dart';
import '../../../services/supabase/profile/client_profile_providers.dart';
import '../../auth/providers/auth_notifier.dart';

/// Identifiants prestataire favoris du client connecté (cache local + sync Supabase).
final clientFavoritePrestataireIdsProvider =
    AsyncNotifierProvider<ClientFavoritePrestataireIdsNotifier, Set<String>>(
  ClientFavoritePrestataireIdsNotifier.new,
);

final isPrestataireFavoriteProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(clientFavoritePrestataireIdsProvider).maybeWhen(
        data: (ids) => ids.contains(id),
        orElse: () => false,
      );
});

final clientFavoritesCountProvider = Provider<int>((ref) {
  return ref.watch(clientFavoritePrestataireIdsProvider).maybeWhen(
        data: (ids) => ids.length,
        orElse: () => 0,
      );
});

class ClientFavoritePrestataireIdsNotifier extends AsyncNotifier<Set<String>> {
  String? _activeClientId;

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
      if (prevUid != null && nextUid == null) {
        unawaited(purgeForLogout());
      }
      ref.invalidateSelf();
    });

    final user = switch (ref.watch(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (user == null) {
      _activeClientId = null;
      return {};
    }

    final client = await ref.watch(currentClientProfileProvider.future);
    final service = ref.watch(favoriServiceProvider);
    if (client == null) {
      _activeClientId = null;
      return {};
    }

    _activeClientId = client.id;
    final local = await ClientFavoritesLocalStore.readIds(client.id);

    if (service != null) {
      unawaited(_reconcileWithServer(clientId: client.id, service: service));
    }

    return local;
  }

  /// Déconnexion : efface le cache local (évite tout mélange de compte).
  Future<void> purgeForLogout() async {
    await ClientFavoritesLocalStore.purgeAll();
    _activeClientId = null;
    state = const AsyncData({});
  }

  Future<void> toggle(String prestataireId) async {
    final client = await ref.read(currentClientProfileProvider.future);
    if (client == null) {
      throw StateError('Profil client requis pour les favoris.');
    }

    final previous = switch (state) {
      AsyncData(:final value) => value,
      _ => await ClientFavoritesLocalStore.readIds(client.id),
    };
    final wasFavorite = previous.contains(prestataireId);
    final optimistic = wasFavorite
        ? (Set<String>.from(previous)..remove(prestataireId))
        : {...previous, prestataireId};

    state = AsyncData(optimistic);
    await ClientFavoritesLocalStore.writeIds(client.id, optimistic);

    unawaited(
      _syncToggleInBackground(
        clientId: client.id,
        prestataireId: prestataireId,
        wasFavorite: wasFavorite,
      ),
    );
  }

  Future<void> _syncToggleInBackground({
    required String clientId,
    required String prestataireId,
    required bool wasFavorite,
  }) async {
    final service = ref.read(favoriServiceProvider);
    if (service == null) {
      await ClientFavoritesLocalStore.enqueuePending(
        clientId,
        FavoritePendingOp(
          prestataireId: prestataireId,
          kind: wasFavorite
              ? FavoriteSyncOpKind.remove
              : FavoriteSyncOpKind.add,
        ),
      );
      return;
    }

    try {
      if (wasFavorite) {
        await service.remove(
          clientId: clientId,
          prestataireId: prestataireId,
        );
      } else {
        await service.add(
          clientId: clientId,
          prestataireId: prestataireId,
        );
      }
    } catch (_) {
      await ClientFavoritesLocalStore.enqueuePending(
        clientId,
        FavoritePendingOp(
          prestataireId: prestataireId,
          kind: wasFavorite
              ? FavoriteSyncOpKind.remove
              : FavoriteSyncOpKind.add,
        ),
      );
    }
  }

  Future<void> _reconcileWithServer({
    required String clientId,
    required FavoriService service,
  }) async {
    await _flushPending(clientId: clientId, service: service);

    try {
      final remote =
          (await service.listPrestataireIds(clientId)).toSet();
      final pending = await ClientFavoritesLocalStore.readPending(clientId);
      if (pending.isNotEmpty) return;

      final local = await ClientFavoritesLocalStore.readIds(clientId);
      if (remote != local) {
        await ClientFavoritesLocalStore.writeIds(clientId, remote);
        if (_activeClientId == clientId) {
          state = AsyncData(remote);
        }
      }
    } catch (_) {
      // Conserve le cache local.
    }
  }

  Future<void> _flushPending({
    required String clientId,
    required FavoriService service,
  }) async {
    var pending = await ClientFavoritesLocalStore.readPending(clientId);
    if (pending.isEmpty) return;

    final remaining = <FavoritePendingOp>[];
    for (var i = 0; i < pending.length; i++) {
      final op = pending[i];
      try {
        switch (op.kind) {
          case FavoriteSyncOpKind.add:
            await service.add(
              clientId: clientId,
              prestataireId: op.prestataireId,
            );
          case FavoriteSyncOpKind.remove:
            await service.remove(
              clientId: clientId,
              prestataireId: op.prestataireId,
            );
        }
      } catch (_) {
        remaining.addAll(pending.sublist(i));
        break;
      }
    }

    await ClientFavoritesLocalStore.writePending(clientId, remaining);
  }
}

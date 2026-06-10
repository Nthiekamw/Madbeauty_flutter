import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/likes/prestataire_like_providers.dart';
import '../../../services/supabase/profile/client_profile_providers.dart';
import '../../auth/providers/auth_notifier.dart';

/// Prestataires likés par le client connecté.
final clientLikedPrestataireIdsProvider =
    AsyncNotifierProvider<ClientLikedPrestataireIdsNotifier, Set<String>>(
  ClientLikedPrestataireIdsNotifier.new,
);

final isPrestataireLikedProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(clientLikedPrestataireIdsProvider).maybeWhen(
        data: (ids) => ids.contains(id),
        orElse: () => false,
      );
});

class ClientLikedPrestataireIdsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    ref.listen(authNotifierProvider, (_, next) {
      final signedOut = switch (next) {
        AsyncData(:final value) => value == null,
        _ => false,
      };
      if (signedOut) {
        state = const AsyncData({});
      } else {
        ref.invalidateSelf();
      }
    });

    final user = switch (ref.watch(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (user == null) return {};

    final client = await ref.watch(currentClientProfileProvider.future);
    final service = ref.watch(prestataireLikeServiceProvider);
    if (client == null || service == null) return {};

    final ids = await service.listLikedPrestataireIds(client.id);
    return ids.toSet();
  }

  Future<void> toggle(String prestataireId) async {
    final client = await ref.read(currentClientProfileProvider.future);
    if (client == null) {
      throw StateError('Profil client requis pour liker.');
    }

    final service = ref.read(prestataireLikeServiceProvider);
    if (service == null) {
      throw StateError('Service like indisponible.');
    }

    final previous = switch (state) {
      AsyncData(:final value) => value,
      _ => <String>{},
    };
    final wasLiked = previous.contains(prestataireId);
    final optimistic = wasLiked
        ? (Set<String>.from(previous)..remove(prestataireId))
        : {...previous, prestataireId};

    state = AsyncData(optimistic);
    ref.invalidate(prestataireLikesCountProvider(prestataireId));

    try {
      if (wasLiked) {
        await service.unlike(
          clientId: client.id,
          prestataireId: prestataireId,
        );
      } else {
        await service.like(
          clientId: client.id,
          prestataireId: prestataireId,
        );
      }
    } catch (e) {
      state = AsyncData(previous);
      ref.invalidate(prestataireLikesCountProvider(prestataireId));
      rethrow;
    }
  }
}

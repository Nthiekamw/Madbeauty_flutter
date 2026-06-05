import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/storage/local_cache_service.dart';
import '../providers/auth_notifier.dart';

/// Mode « continuer sans compte » – **session en cours uniquement** (non mémorisé
/// au redémarrage de l'app, pour ne pas écraser la connexion / bienvenue).
final guestModeProvider = NotifierProvider<GuestModeNotifier, bool>(
  GuestModeNotifier.new,
);

/// Invité actif : pas de session Supabase mais navigation client autorisée.
final isGuestBrowsingProvider = Provider<bool>((ref) {
  if (!ref.watch(guestModeProvider)) return false;
  final user = switch (ref.watch(authNotifierProvider)) {
    AsyncData(:final value) => value,
    _ => null,
  };
  return user == null;
});

/// Quitte le mode invité (ex. ouverture connexion / inscription).
Future<void> exitGuestMode(WidgetRef ref) =>
    ref.read(guestModeProvider.notifier).disable();

class GuestModeNotifier extends Notifier<bool> {
  static bool _legacyFlagCleared = false;

  @override
  bool build() {
    ref.listen(authNotifierProvider, (previous, next) {
      final user = switch (next) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (user != null && state) {
        unawaited(disable());
      }
    });

    _clearLegacyPersistedFlagOnce();
    return false;
  }

  void _clearLegacyPersistedFlagOnce() {
    if (_legacyFlagCleared) return;
    _legacyFlagCleared = true;
    if (LocalCacheService.instance.guestModeActive) {
      unawaited(LocalCacheService.instance.setGuestModeActive(false));
    }
  }

  /// Active la navigation invitée pour cette session d'app seulement.
  void enable() {
    state = true;
  }

  Future<void> disable() async {
    await LocalCacheService.instance.setGuestModeActive(false);
    state = false;
  }
}


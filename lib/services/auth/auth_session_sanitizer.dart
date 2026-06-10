import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Gestion des sessions Supabase invalides (refresh token révoqué ou introuvable).
abstract final class AuthSessionSanitizer {
  AuthSessionSanitizer._();

  static bool isStaleSessionError(Object error) {
    if (error is! AuthException) return false;
    final code = error.code?.toLowerCase();
    if (code == 'refresh_token_not_found') return true;
    final message = error.message.toLowerCase();
    return message.contains('refresh token not found') ||
        message.contains('invalid refresh token');
  }

  /// Réseau indisponible (DNS, hors ligne) — ne pas déconnecter l’utilisateur.
  static bool isTransientNetworkError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('no address associated with hostname') ||
        text.contains('network is unreachable') ||
        text.contains('connection refused') ||
        text.contains('connection timed out') ||
        text.contains('authretryablefetchexception');
  }

  /// Déconnexion locale sans remonter d'erreur (session déjà absente côté serveur).
  static Future<void> signOutLocally(GoTrueClient auth) async {
    try {
      await auth.signOut();
    } on AuthException {
      // Session déjà invalide : le stockage local est nettoyé par signOut.
    } catch (_) {}
  }

  /// Écouteur de secours pendant [Supabase.initialize] (recoverSession en arrière-plan).
  static StreamSubscription<AuthState> installStartupGuard(GoTrueClient auth) {
    return auth.onAuthStateChange.listen(
      (_) {},
      onError: (error, stackTrace) {
        if (isTransientNetworkError(error)) return;
        if (isStaleSessionError(error)) {
          unawaited(signOutLocally(auth));
        }
      },
    );
  }

  /// Convertit les erreurs de refresh en événement `signedOut` pour l'UI.
  static Stream<AuthState> streamWithRecovery(GoTrueClient auth) {
    return auth.onAuthStateChange.transform(
      StreamTransformer<AuthState, AuthState>.fromHandlers(
        handleData: (data, sink) => sink.add(data),
        handleError: (error, stackTrace, sink) async {
          if (isTransientNetworkError(error)) return;
          if (isStaleSessionError(error)) {
            await signOutLocally(auth);
            sink.add(const AuthState(AuthChangeEvent.signedOut, null));
            return;
          }
          sink.addError(error, stackTrace);
        },
      ),
    );
  }
}


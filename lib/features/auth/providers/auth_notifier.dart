import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../services/auth/auth_service.dart';

/// Accès à [AuthService] (nécessite Supabase configuré au lancement).
final authServiceProvider = Provider<AuthService>((ref) {
  if (!AppConfig.hasSupabase) {
    throw StateError(
      'authServiceProvider : définir SUPABASE_URL et SUPABASE_ANON_KEY '
      '(ex. --dart-define-from-file=.env).',
    );
  }
  return AuthService.fromEnv();
});

/// Flux [AuthState] de Supabase : `initialSession`, `signedIn`, `signedOut`,
/// `tokenRefreshed`, `userUpdated`, `passwordRecovery`, etc.
///
/// À utiliser quand l’UI a besoin de l’événement brut (ex. recovery).
/// L’utilisateur courant dérivé reste sur [authNotifierProvider].
final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  if (!AppConfig.hasSupabase) {
    return Stream<AuthState>.value(
      const AuthState(AuthChangeEvent.signedOut, null),
    );
  }
  final auth = ref.watch(authServiceProvider);
  return auth.onAuthStateChange;
});

/// État d’authentification : [User] connecté ou `null`.
///
/// Synchronisé sur [authStateStreamProvider] (donc sur `onAuthStateChange`)
/// et expose connexion / déconnexion.
final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<User?> {
  AuthService get _auth => ref.read(authServiceProvider);

  @override
  Future<User?> build() async {
    if (!AppConfig.hasSupabase) {
      return null;
    }

    final subscription = ref.listen<AsyncValue<AuthState>>(
      authStateStreamProvider,
      (previous, next) {
        next.when(
          data: (authState) {
            state = AsyncData(authState.session?.user);
          },
          error: (error, stackTrace) {
            state = AsyncError(error, stackTrace);
          },
          loading: () {},
        );
      },
      fireImmediately: true,
    );

    ref.onDispose(subscription.close);

    return _auth.currentSession?.user;
  }

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (!AppConfig.hasSupabase) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user ?? _auth.currentUser;
    });
  }

  Future<void> signOut() async {
    if (!AppConfig.hasSupabase) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _auth.signOut();
      return null;
    });
  }
}

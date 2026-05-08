import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../services/auth/auth_service.dart';
import '../../../services/auth/role_service.dart';
import '../../../services/storage/local_cache_service.dart';

/// Accès à [AuthService] (nécessite Supabase configuré au lancement).
final authSupabaseEnabledProvider = Provider<bool>((ref) {
  return AppConfig.hasSupabase;
});

/// Accès à [AuthService] (nécessite Supabase configuré au lancement).
final authServiceProvider = Provider<AuthService>((ref) {
  if (!ref.read(authSupabaseEnabledProvider)) {
    throw StateError(
      'authServiceProvider : définir SUPABASE_URL et SUPABASE_ANON_KEY '
      '(ex. --dart-define-from-file=.env).',
    );
  }
  return AuthService.fromEnv();
});

final roleServiceProvider = Provider<RoleService>((ref) {
  if (!ref.read(authSupabaseEnabledProvider)) {
    throw StateError(
      'roleServiceProvider : définir SUPABASE_URL et SUPABASE_ANON_KEY '
      '(ex. --dart-define-from-file=.env).',
    );
  }
  return RoleService.fromEnv();
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

  Future<void> _cacheCurrentEmail(User? user) async {
    final email = user?.email;
    if (email == null || email.isEmpty) {
      await LocalCacheService.instance.remove(LocalCacheService.lastSignedInEmailKey);
      await LocalCacheService.instance.remove(LocalCacheService.profileSnapshotKey);
      await LocalCacheService.instance.clearSelectedRole();
      return;
    }
    await LocalCacheService.instance.setString(
      LocalCacheService.lastSignedInEmailKey,
      email,
    );
  }

  @override
  Future<User?> build() async {
    if (!ref.read(authSupabaseEnabledProvider)) {
      return null;
    }

    final subscription = ref.listen<AsyncValue<AuthState>>(
      authStateStreamProvider,
      (previous, next) {
        next.when(
          data: (authState) {
            final streamUser = authState.session?.user ?? _auth.currentUser;
            state = AsyncData(streamUser);
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

    final initialUser = _auth.currentSession?.user;
    await _cacheCurrentEmail(initialUser);
    return initialUser;
  }

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (!ref.read(authSupabaseEnabledProvider)) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user ?? _auth.currentSession?.user ?? _auth.currentUser;
      await _cacheCurrentEmail(user);
      return user;
    });
  }

  Future<void> signOut() async {
    if (!ref.read(authSupabaseEnabledProvider)) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _auth.signOut();
      await _cacheCurrentEmail(null);
      return null;
    });
  }

  Future<void> signUpWithPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (!ref.read(authSupabaseEnabledProvider)) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {'full_name': displayName},
        emailRedirectTo: AppConfig.authEmailRedirectTo,
      );
      final user = response.user ?? _auth.currentSession?.user ?? _auth.currentUser;
      await _cacheCurrentEmail(user);
      return user;
    });
  }
}

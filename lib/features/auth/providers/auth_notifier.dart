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
  static const _initialSessionTimeout = Duration(seconds: 2);

  AuthService get _auth => ref.read(authServiceProvider);

  Future<void> _cacheCurrentEmail(User? user) async {
    final email = user?.email;
    if (email == null || email.isEmpty) {
      return;
    }
    await LocalCacheService.instance.setString(
      LocalCacheService.lastSignedInEmailKey,
      email,
    );
  }

  Future<void> _clearAuthCache() async {
    await LocalCacheService.instance.remove(LocalCacheService.lastSignedInEmailKey);
    await LocalCacheService.instance.remove(LocalCacheService.profileSnapshotKey);
    await LocalCacheService.instance.clearSelectedRole();
    await LocalCacheService.instance.clearCachedServerRoles();
  }

  Future<User?> _readInitialUser() async {
    final current = _auth.currentSession?.user ?? _auth.currentUser;
    if (current != null) return current;

    try {
      final authState = await _auth.onAuthStateChange.first.timeout(
        _initialSessionTimeout,
      );
      return authState.session?.user ??
          _auth.currentSession?.user ??
          _auth.currentUser;
    } catch (_) {
      return _auth.currentSession?.user ?? _auth.currentUser;
    }
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

    final initialUser = await _readInitialUser();
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
      await _clearAuthCache();
      return null;
    });
  }

  Future<void> signUpWithPassword({
    required String email,
    required String password,
    required String displayName,
    String? prenom,
    String? nom,
    String? phone,
  }) async {
    if (!ref.read(authSupabaseEnabledProvider)) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final meta = <String, dynamic>{
        'full_name': displayName,
        if ((prenom ?? '').trim().isNotEmpty) 'prenom': prenom!.trim(),
        if ((nom ?? '').trim().isNotEmpty) 'nom': nom!.trim(),
        if ((phone ?? '').trim().isNotEmpty) 'phone': phone!.trim(),
      };
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: meta,
        emailRedirectTo: AppConfig.authEmailRedirectTo,
      );
      final user = response.user ?? _auth.currentSession?.user ?? _auth.currentUser;
      await _cacheCurrentEmail(user);
      return user;
    });
  }

  Future<void> verifyOtpEmailSignIn({
    required String email,
    required String token,
  }) async {
    if (!ref.read(authSupabaseEnabledProvider)) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await _auth.verifyOtpEmailSignIn(email: email, token: token);
      final user = response.user ?? _auth.currentSession?.user ?? _auth.currentUser;
      await _cacheCurrentEmail(user);
      return user;
    });
  }

  Future<void> verifyOtpSmsSignIn({
    required String phone,
    required String token,
  }) async {
    if (!ref.read(authSupabaseEnabledProvider)) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await _auth.verifyOtpSmsSignIn(phone: phone, token: token);
      final user = response.user ?? _auth.currentSession?.user ?? _auth.currentUser;
      await _cacheCurrentEmail(user);
      return user;
    });
  }

  /// Ouvre le navigateur / onglet OAuth ; la session arrive via deep link (PKCE).
  Future<void> signInWithGoogle() async {
    if (!ref.read(authSupabaseEnabledProvider)) return;
    await _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConfig.authEmailRedirectTo,
    );
  }

  /// Après ouverture du lien « mot de passe oublié » (session recovery).
  Future<void> updatePassword(String newPassword) async {
    if (!ref.read(authSupabaseEnabledProvider)) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _auth.updateUser(UserAttributes(password: newPassword));
      final user = _auth.currentSession?.user ?? _auth.currentUser;
      await _cacheCurrentEmail(user);
      return user;
    });
  }
}

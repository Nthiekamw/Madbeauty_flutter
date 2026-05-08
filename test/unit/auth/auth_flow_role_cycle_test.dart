import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madbeauty/core/config/app_config.dart';
import 'package:madbeauty/features/auth/providers/auth_notifier.dart';
import 'package:madbeauty/services/auth/auth_service.dart';
import 'package:madbeauty/services/storage/local_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalCacheService.initialize();
    AppConfig.debugSupabaseEnabledOverride = true;
  });

  tearDown(() {
    AppConfig.debugSupabaseEnabledOverride = null;
  });

  test('inscription -> choix role -> deconnexion -> reconnexion', () async {
    final fakeService = _CycleAuthService();
    final container = ProviderContainer(
      overrides: [
        authSupabaseEnabledProvider.overrideWithValue(true),
        authServiceProvider.overrideWithValue(fakeService),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authNotifierProvider.future);

    // 1) Inscription
    await container.read(authNotifierProvider.notifier).signUpWithPassword(
          email: 'cycle@madbeauty.app',
          password: 'password123',
          displayName: 'Cycle User',
        );
    final afterSignup = container.read(authNotifierProvider);
    expect(afterSignup.value?.email, 'cycle@madbeauty.app');

    // 2) Choix role (persist local)
    await LocalCacheService.instance.setSelectedRole('prestataire');
    expect(LocalCacheService.instance.selectedRole, 'prestataire');

    // 3) Deconnexion
    await container.read(authNotifierProvider.notifier).signOut();
    final afterSignOut = container.read(authNotifierProvider);
    expect(afterSignOut.value, isNull);
    expect(
      LocalCacheService.instance.getString(LocalCacheService.lastSignedInEmailKey),
      isNull,
    );
    expect(LocalCacheService.instance.selectedRole, isNull);

    // 4) Reconnexion
    await container.read(authNotifierProvider.notifier).signInWithPassword(
          email: 'cycle@madbeauty.app',
          password: 'password123',
        );
    final afterSignIn = container.read(authNotifierProvider);
    expect(afterSignIn.value?.email, 'cycle@madbeauty.app');
  });
}

class _CycleAuthService extends AuthService {
  _CycleAuthService()
      : _stream = Stream<AuthState>.value(
          const AuthState(AuthChangeEvent.signedOut, null),
        ),
        super(SupabaseClient('https://example.supabase.co', 'anon-key'));

  final Stream<AuthState> _stream;
  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  @override
  Session? get currentSession => null;

  @override
  Stream<AuthState> get onAuthStateChange => _stream;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
    String? emailRedirectTo,
  }) async {
    _currentUser = _userWithEmail(email, fullName: data?['full_name'] as String?);
    return AuthResponse(user: _currentUser, session: null);
  }

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    _currentUser = _userWithEmail(email);
    return AuthResponse(user: _currentUser, session: null);
  }

  @override
  Future<void> signOut({SignOutScope scope = SignOutScope.global}) async {
    _currentUser = null;
  }
}

User _userWithEmail(String email, {String? fullName}) {
  return User.fromJson({
    'id': 'uid-cycle',
    'aud': 'authenticated',
    'role': 'authenticated',
    'email': email,
    'phone': '',
    'app_metadata': <String, dynamic>{},
    'user_metadata': <String, dynamic>{
      'full_name': fullName ?? 'Cycle User',
    },
    'identities': <dynamic>[],
    'created_at': '2026-01-01T00:00:00.000Z',
    'updated_at': '2026-01-01T00:00:00.000Z',
    'is_anonymous': false,
  })!;
}

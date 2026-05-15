import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madbeauty/features/auth/providers/auth_notifier.dart';
import 'package:madbeauty/services/auth/auth_service.dart';
import 'package:madbeauty/services/storage/local_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalCacheService.initialize();
  });

  test('signInWithPassword met en cache l’email utilisateur', () async {
    final fakeService = _FakeAuthService(
      signInUser: _userWithEmail('signin@madbeauty.app'),
      stream: Stream<AuthState>.value(
        const AuthState(AuthChangeEvent.signedOut, null),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        authSupabaseEnabledProvider.overrideWithValue(true),
        authServiceProvider.overrideWithValue(fakeService),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authNotifierProvider.future);
    await container.read(authNotifierProvider.notifier).signInWithPassword(
          email: 'signin@madbeauty.app',
          password: 'secret',
        );

    expect(
      LocalCacheService.instance.getString(LocalCacheService.lastSignedInEmailKey),
      'signin@madbeauty.app',
    );
  });

  test('signUpWithPassword met en cache l’email utilisateur', () async {
    final fakeService = _FakeAuthService(
      signUpUser: _userWithEmail('signup@madbeauty.app'),
      stream: Stream<AuthState>.value(
        const AuthState(AuthChangeEvent.signedOut, null),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        authSupabaseEnabledProvider.overrideWithValue(true),
        authServiceProvider.overrideWithValue(fakeService),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authNotifierProvider.future);
    await container.read(authNotifierProvider.notifier).signUpWithPassword(
          email: 'signup@madbeauty.app',
          password: 'secret',
          displayName: 'Signup User',
        );

    expect(
      LocalCacheService.instance.getString(LocalCacheService.lastSignedInEmailKey),
      'signup@madbeauty.app',
    );
  });

  test('signOut vide les cles de cache email + profil', () async {
    await LocalCacheService.instance.setString(
      LocalCacheService.lastSignedInEmailKey,
      'cached@madbeauty.app',
    );
    await LocalCacheService.instance.setString(
      LocalCacheService.profileSnapshotKey,
      '{"email":"cached@madbeauty.app"}',
    );
    await LocalCacheService.instance.setSelectedRole('prestataire');

    final fakeService = _FakeAuthService(
      initialUser: _userWithEmail('cached@madbeauty.app'),
      stream: Stream<AuthState>.value(
        const AuthState(AuthChangeEvent.signedOut, null),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        authSupabaseEnabledProvider.overrideWithValue(true),
        authServiceProvider.overrideWithValue(fakeService),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authNotifierProvider.future);
    await container.read(authNotifierProvider.notifier).signOut();

    expect(
      LocalCacheService.instance.getString(LocalCacheService.lastSignedInEmailKey),
      isNull,
    );
    expect(
      LocalCacheService.instance.getString(LocalCacheService.profileSnapshotKey),
      isNull,
    );
    expect(LocalCacheService.instance.selectedRole, isNull);
  });

  test('restaure la session initiale depuis le flux Supabase au redemarrage', () async {
    final restoredUser = _userWithEmail('restored@madbeauty.app');
    final fakeService = _FakeAuthService(
      stream: Stream<AuthState>.value(
        AuthState(
          AuthChangeEvent.initialSession,
          _sessionWithUser(restoredUser),
        ),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        authSupabaseEnabledProvider.overrideWithValue(true),
        authServiceProvider.overrideWithValue(fakeService),
      ],
    );
    addTearDown(container.dispose);

    final user = await container.read(authNotifierProvider.future);

    expect(user?.email, 'restored@madbeauty.app');
    expect(
      LocalCacheService.instance.getString(LocalCacheService.lastSignedInEmailKey),
      'restored@madbeauty.app',
    );
  });

  test('ne vide pas le role local si aucune session initiale est trouvee', () async {
    await LocalCacheService.instance.setSelectedRole('prestataire');
    final fakeService = _FakeAuthService(
      stream: Stream<AuthState>.value(
        const AuthState(AuthChangeEvent.initialSession, null),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        authSupabaseEnabledProvider.overrideWithValue(true),
        authServiceProvider.overrideWithValue(fakeService),
      ],
    );
    addTearDown(container.dispose);

    final user = await container.read(authNotifierProvider.future);

    expect(user, isNull);
    expect(LocalCacheService.instance.selectedRole, 'prestataire');
  });
}

User _userWithEmail(String email) {
  return User.fromJson({
    'id': 'uid-1',
    'aud': 'authenticated',
    'role': 'authenticated',
    'email': email,
    'phone': '',
    'app_metadata': <String, dynamic>{},
    'user_metadata': <String, dynamic>{'full_name': 'Test User'},
    'identities': <dynamic>[],
    'created_at': '2026-01-01T00:00:00.000Z',
    'updated_at': '2026-01-01T00:00:00.000Z',
    'is_anonymous': false,
  })!;
}

Session _sessionWithUser(User user) {
  return Session(
    accessToken: 'access-token',
    tokenType: 'bearer',
    user: user,
    expiresIn: 3600,
    refreshToken: 'refresh-token',
  );
}

class _FakeAuthService extends AuthService {
  _FakeAuthService({
    this.initialUser,
    this.signInUser,
    this.signUpUser,
    required Stream<AuthState> stream,
  })  : _stream = stream,
        super(SupabaseClient('https://example.supabase.co', 'anon-key'));

  final User? initialUser;
  final User? signInUser;
  final User? signUpUser;
  final Stream<AuthState> _stream;

  User? _currentUser;

  @override
  User? get currentUser => _currentUser ?? initialUser;

  @override
  Session? get currentSession => null;

  @override
  Stream<AuthState> get onAuthStateChange => _stream;

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    _currentUser = signInUser;
    return AuthResponse(user: signInUser, session: null);
  }

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
    String? emailRedirectTo,
  }) async {
    _currentUser = signUpUser;
    return AuthResponse(user: signUpUser, session: null);
  }

  @override
  Future<void> signOut({SignOutScope scope = SignOutScope.global}) async {
    _currentUser = null;
  }
}

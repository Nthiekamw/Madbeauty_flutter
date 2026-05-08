import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madbeauty/core/providers/runtime_providers.dart';
import 'package:madbeauty/features/home/models/home_profile_snapshot.dart';
import 'package:madbeauty/features/home/providers/home_profile_provider.dart';
import 'package:madbeauty/services/network/connectivity_service.dart';
import 'package:madbeauty/services/storage/local_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<HomeProfileSnapshot?> readSnapshot({
    bool isOnline = false,
    bool supabaseEnabled = false,
    HomeAuthSeed? authSeed,
    Future<HomeProfileSnapshot?> Function()? remoteLoader,
  }) async {
    final container = ProviderContainer(
      overrides: [
        connectivityServiceProvider.overrideWithValue(
          _FakeConnectivityService(isOnline: isOnline),
        ),
        supabaseEnabledProvider.overrideWithValue(supabaseEnabled),
        if (authSeed != null) homeAuthSeedProvider.overrideWithValue(authSeed),
        if (remoteLoader != null)
          homeProfileRemoteLoaderProvider.overrideWithValue(remoteLoader),
      ],
    );
    addTearDown(container.dispose);
    return container.read(homeProfileSnapshotProvider.future);
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalCacheService.initialize();
  });

  test('retourne null si aucun cache local', () async {
    final snapshot = await readSnapshot();
    expect(snapshot, isNull);
  });

  test('retourne le profil depuis le cache local quand present', () async {
    await LocalCacheService.instance.setString(
      LocalCacheService.profileSnapshotKey,
      jsonEncode(const {
        'email': 'cached@madbeauty.app',
        'display_name': 'Cached User',
      }),
    );

    final snapshot = await readSnapshot();

    expect(snapshot, isNotNull);
    expect(snapshot!.email, 'cached@madbeauty.app');
    expect(snapshot.displayName, 'Cached User');
    expect(snapshot.isFromCache, isTrue);
  });

  test('ignore un cache invalide (json corrompu)', () async {
    await LocalCacheService.instance.setString(
      LocalCacheService.profileSnapshotKey,
      '{invalid-json',
    );

    final snapshot = await readSnapshot();
    expect(snapshot, isNull);
  });

  test('online refresh retourne profil live et met a jour le cache', () async {
    final snapshot = await readSnapshot(
      isOnline: true,
      supabaseEnabled: true,
      authSeed: const HomeAuthSeed(
        email: 'seed@madbeauty.app',
        displayName: 'Seed',
      ),
      remoteLoader: () async => const HomeProfileSnapshot(
        email: 'live@madbeauty.app',
        displayName: 'Live User',
        isFromCache: false,
      ),
    );

    expect(snapshot, isNotNull);
    expect(snapshot!.email, 'live@madbeauty.app');
    expect(snapshot.displayName, 'Live User');
    expect(snapshot.isFromCache, isFalse);

    final cachedRaw =
        LocalCacheService.instance.getString(LocalCacheService.profileSnapshotKey);
    expect(cachedRaw, isNotNull);
    expect(cachedRaw, contains('live@madbeauty.app'));
  });

  test('online refresh fallback sur cache si remote en erreur', () async {
    await LocalCacheService.instance.setString(
      LocalCacheService.profileSnapshotKey,
      jsonEncode(const {
        'email': 'cached@madbeauty.app',
        'display_name': 'Cached User',
      }),
    );

    final snapshot = await readSnapshot(
      isOnline: true,
      supabaseEnabled: true,
      authSeed: const HomeAuthSeed(
        email: 'seed@madbeauty.app',
        displayName: 'Seed',
      ),
      remoteLoader: () async => throw Exception('network error'),
    );

    expect(snapshot, isNotNull);
    expect(snapshot!.email, 'cached@madbeauty.app');
    expect(snapshot.displayName, 'Cached User');
    expect(snapshot.isFromCache, isTrue);
  });
}

class _FakeConnectivityService extends ConnectivityService {
  _FakeConnectivityService({required bool isOnline})
      : _online = isOnline,
        super(Connectivity());

  final bool _online;

  @override
  Stream<bool> get onlineStatusStream => Stream<bool>.value(_online);

  @override
  Future<bool> isOnline() async => _online;
}

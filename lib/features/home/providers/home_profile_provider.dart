import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/providers/runtime_providers.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../auth/providers/auth_notifier.dart';
import '../models/home_profile_snapshot.dart';

class HomeAuthSeed {
  const HomeAuthSeed({
    required this.email,
    required this.displayName,
  });

  final String email;
  final String displayName;
}

final supabaseEnabledProvider = Provider<bool>((ref) => AppConfig.hasSupabase);

final homeAuthSeedProvider = Provider<HomeAuthSeed?>((ref) {
  final auth = ref.watch(authNotifierProvider);
  final User? user = switch (auth) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (user == null) return null;

  return HomeAuthSeed(
    email: user.email ?? '',
    displayName: (user.userMetadata?['full_name'] as String?) ?? '',
  );
});

final homeProfileRemoteLoaderProvider =
    Provider<Future<HomeProfileSnapshot?> Function()>((ref) {
      return () async {
        final authService = ref.read(authServiceProvider);
        final remoteUser = (await authService.getUser()).user;
        if (remoteUser == null) return null;
        return HomeProfileSnapshot(
          email: remoteUser.email ?? '',
          displayName: (remoteUser.userMetadata?['full_name'] as String?) ?? '',
          isFromCache: false,
        );
      };
    });

final homeProfileSnapshotProvider = FutureProvider<HomeProfileSnapshot?>((ref) async {
  final isOnline = await ref.read(connectivityServiceProvider).isOnline();
  final cache = LocalCacheService.instance;

  HomeProfileSnapshot? fromCache;
  final cachedRaw = cache.getString(LocalCacheService.profileSnapshotKey);
  if (cachedRaw != null && cachedRaw.isNotEmpty) {
    try {
      final json = jsonDecode(cachedRaw) as Map<String, dynamic>;
      fromCache = HomeProfileSnapshot.fromJson(json, isFromCache: true);
    } catch (_) {
      fromCache = null;
    }
  }

  if (!ref.read(supabaseEnabledProvider)) {
    return fromCache;
  }

  final authSeed = ref.read(homeAuthSeedProvider);
  if (authSeed == null) {
    return fromCache;
  }

  if (!isOnline) {
    return fromCache ??
        HomeProfileSnapshot(
          email: authSeed.email,
          displayName: authSeed.displayName,
          isFromCache: true,
        );
  }

  try {
    final snapshot = await ref.read(homeProfileRemoteLoaderProvider)();
    if (snapshot == null) return fromCache;

    await cache.setString(
      LocalCacheService.profileSnapshotKey,
      jsonEncode(snapshot.toJson()),
    );
    return snapshot;
  } catch (_) {
    return fromCache;
  }
});


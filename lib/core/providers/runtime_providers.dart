import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/network/connectivity_service.dart';
import '../../services/storage/local_cache_service.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService.create();
});

final onlineStatusProvider = StreamProvider<bool>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  return connectivity.onlineStatusStream;
});

final cachedLastSignedInEmailProvider = FutureProvider<String?>((ref) async {
  return LocalCacheService.instance.getString(LocalCacheService.lastSignedInEmailKey);
});


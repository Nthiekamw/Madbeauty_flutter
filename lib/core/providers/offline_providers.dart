import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/offline/offline_data_loader.dart';
import 'runtime_providers.dart';

/// `true` tant que la connectivité n’est pas connue (évite un flash « hors ligne »).
final isOnlineProvider = Provider<bool>((ref) {
  final status = ref.watch(onlineStatusProvider);
  return switch (status) {
    AsyncData(:final value) => value,
    _ => true,
  };
});

final offlineModeProvider = Provider<bool>(
  (ref) => !ref.watch(isOnlineProvider),
);

final offlineDataLoaderProvider = Provider<OfflineDataLoader>((ref) {
  return OfflineDataLoader(ref.watch(connectivityServiceProvider));
});

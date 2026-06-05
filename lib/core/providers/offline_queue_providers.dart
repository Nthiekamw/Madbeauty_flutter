import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/offline/offline_action_queue_store.dart'
    show OfflineActionQueueStore, compactOfflineQueue;
import '../../services/offline/offline_sync_service.dart';
import '../../services/offline/pending_offline_action.dart';
import 'offline_providers.dart';
import 'runtime_providers.dart';

/// Dernier résultat de synchro (snackbar dans [OfflineShell]).
final lastOfflineSyncResultProvider =
    NotifierProvider<LastOfflineSyncResultNotifier, OfflineSyncResult?>(
      LastOfflineSyncResultNotifier.new,
    );

class LastOfflineSyncResultNotifier extends Notifier<OfflineSyncResult?> {
  @override
  OfflineSyncResult? build() => null;

  set value(OfflineSyncResult? result) => state = result;
}

final offlineSyncServiceProvider = Provider<OfflineSyncService>(
  (ref) => OfflineSyncService(ref),
);

final offlineActionQueueProvider =
    NotifierProvider<OfflineActionQueueNotifier, List<PendingOfflineAction>>(
      OfflineActionQueueNotifier.new,
    );

final offlineQueuePendingCountProvider = Provider<int>(
  (ref) => ref.watch(offlineActionQueueProvider).length,
);

class OfflineActionQueueNotifier extends Notifier<List<PendingOfflineAction>> {
  bool _flushing = false;

  @override
  List<PendingOfflineAction> build() {
    ref.listen(onlineStatusProvider, (previous, next) {
      next.whenData((online) {
        if (!online) return;
        final wasOffline = previous?.asData?.value == false;
        if (wasOffline) unawaited(flush());
      });
    });

    scheduleMicrotask(() {
      if (ref.read(isOnlineProvider)) unawaited(flush());
    });

    return OfflineActionQueueStore.instance.readAll();
  }

  Future<void> enqueue(PendingOfflineAction action) async {
    final next = compactOfflineQueue([...state, action]);
    await OfflineActionQueueStore.instance.replace(next);
    state = next;
  }

  Future<OfflineSyncResult?> flush() async {
    if (_flushing) return null;
    if (!ref.read(isOnlineProvider)) return null;

    _flushing = true;
    try {
      final result = await ref.read(offlineSyncServiceProvider).flush();
      state = OfflineActionQueueStore.instance.readAll();
      if (result.hasWork) {
        ref.read(lastOfflineSyncResultProvider.notifier).value = result;
      }
      return result;
    } finally {
      _flushing = false;
    }
  }
}


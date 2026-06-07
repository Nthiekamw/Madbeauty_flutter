import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logic/booking/booking_create_failure.dart';
import '../../core/models/domain/booking/client_reservation_summary.dart';
import '../../core/providers/offline_providers.dart';
import '../../core/providers/offline_sync_hooks.dart';
import '../../services/supabase/booking/booking_service.dart';
import '../../services/supabase/booking/booking_service_providers.dart';
import 'offline_action_queue_store.dart'
    show OfflineActionQueueStore, compactOfflineQueue;
import 'pending_offline_action.dart';

class OfflineSyncResult {
  const OfflineSyncResult({
    required this.syncedCount,
    required this.failedCount,
    required this.removedCount,
  });

  final int syncedCount;
  final int failedCount;
  final int removedCount;

  bool get hasWork => syncedCount > 0 || removedCount > 0;
}

/// Rejoue la file d'actions lorsque le réseau est disponible.
class OfflineSyncService {
  OfflineSyncService(this._ref);

  final Ref _ref;

  Future<OfflineSyncResult> flush() async {
    if (!_ref.read(isOnlineProvider)) {
      return const OfflineSyncResult(
        syncedCount: 0,
        failedCount: 0,
        removedCount: 0,
      );
    }

    final booking = _ref.read(bookingServiceProvider);
    if (booking == null) {
      return const OfflineSyncResult(
        syncedCount: 0,
        failedCount: 0,
        removedCount: 0,
      );
    }

    final store = OfflineActionQueueStore.instance;
    var queue = compactOfflineQueue(store.readAll());
    if (queue.isEmpty) {
      return const OfflineSyncResult(
        syncedCount: 0,
        failedCount: 0,
        removedCount: 0,
      );
    }

    var synced = 0;
    var failed = 0;
    var removed = 0;
    final remaining = <PendingOfflineAction>[];

    for (final action in queue) {
      try {
        final discard = await _execute(booking, action, queue);
        if (discard) {
          removed++;
        } else {
          synced++;
        }
      } catch (error) {
        if (error is BookingSlotTakenFailure) {
          removed++;
          continue;
        }
        failed++;
        final message = bookingCreateFailureMessage(error);
        remaining.add(
          action.copyWith(
            retryCount: action.retryCount + 1,
            lastError: message,
          ),
        );
      }
    }

    await store.replace(remaining);

    if (synced > 0 || removed > 0) {
      _ref.read(offlineSyncAfterFlushProvider)(_ref);
    }

    return OfflineSyncResult(
      syncedCount: synced,
      failedCount: failed,
      removedCount: removed,
    );
  }

  Future<bool> _execute(
    BookingService booking,
    PendingOfflineAction action,
    List<PendingOfflineAction> fullQueue,
  ) async {
    switch (action.type) {
      case OfflineActionType.bookingCreate:
        await booking.create(
          prestataireId: _requireString(action.payload, 'prestataireId'),
          serviceId: _requireString(action.payload, 'serviceId'),
          dateHeure: DateTime.parse(
            _requireString(action.payload, 'dateHeure'),
          ),
          notesClient: action.payload['notesClient'] as String?,
        );
        return false;

      case OfflineActionType.bookingCancel:
        final id = _requireString(action.payload, 'reservationId');
        if (id.startsWith(PendingOfflineAction.localIdPrefix)) {
          return true;
        }
        await booking.cancel(id);
        return false;

      case OfflineActionType.bookingConfirm:
        await booking.confirm(
          _requireString(action.payload, 'reservationId'),
        );
        return false;

      case OfflineActionType.bookingReject:
        await booking.rejectByPrestataire(
          _requireString(action.payload, 'reservationId'),
          reason: action.payload['reason'] as String?,
        );
        return false;

      case OfflineActionType.bookingMarkDone:
        await booking.markAsDone(
          _requireString(action.payload, 'reservationId'),
        );
        return false;

      case OfflineActionType.messageSend:
        throw UnsupportedError('messageSend');
    }
  }

  String _requireString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! String || value.trim().isEmpty) {
      throw StateError('Payload manquant: $key');
    }
    return value;
  }
}

/// Fusionne réservations distantes / cache et créations locales en file.
List<ClientReservationSummary> mergeClientReservationsWithQueue(
  List<ClientReservationSummary> remote,
  List<PendingOfflineAction> queue,
) {
  final cancelledIds = queue
      .where((a) => a.type == OfflineActionType.bookingCancel)
      .map((a) => a.payload['reservationId'] as String?)
      .whereType<String>()
      .toSet();

  final pendingCreates = queue
      .where((a) => a.type == OfflineActionType.bookingCreate)
      .map((a) => a.toPendingClientSummary())
      .whereType<ClientReservationSummary>()
      .toList();

  final mergedRemote = remote.where((r) => !cancelledIds.contains(r.id));

  return [...pendingCreates, ...mergedRemote];
}


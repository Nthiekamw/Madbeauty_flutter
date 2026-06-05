import 'dart:convert';

import '../../services/storage/local_cache_service.dart';
import 'pending_offline_action.dart';

/// Persistance SharedPreferences de la file d'actions hors ligne.
class OfflineActionQueueStore {
  OfflineActionQueueStore._();

  static const String _key = 'offline.action_queue';

  static OfflineActionQueueStore get instance => OfflineActionQueueStore._();

  List<PendingOfflineAction> readAll() {
    final raw = LocalCacheService.instance.getString(_key);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      final items = <PendingOfflineAction>[];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        final action = PendingOfflineAction.fromJson(
          Map<String, dynamic>.from(entry),
        );
        if (action != null) items.add(action);
      }
      items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return items;
    } catch (_) {
      return const [];
    }
  }

  Future<void> writeAll(List<PendingOfflineAction> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await LocalCacheService.instance.setString(_key, encoded);
  }

  Future<void> replace(List<PendingOfflineAction> items) =>
      writeAll(items);

  Future<void> clear() => LocalCacheService.instance.remove(_key);
}

/// Supprime les annulations locales qui annulent une création encore en file.
List<PendingOfflineAction> compactOfflineQueue(
  List<PendingOfflineAction> queue,
) {
  final cancelledLocals = <String>{};
  for (final action in queue) {
    if (action.type != OfflineActionType.bookingCancel) continue;
    final id = action.payload['reservationId'] as String?;
    if (id != null && id.startsWith(PendingOfflineAction.localIdPrefix)) {
      cancelledLocals.add(id);
    }
  }

  return queue.where((action) {
    if (action.type == OfflineActionType.bookingCancel) {
      final id = action.payload['reservationId'] as String?;
      if (id != null && id.startsWith(PendingOfflineAction.localIdPrefix)) {
        return false;
      }
    }
    if (action.type == OfflineActionType.bookingCreate) {
      final localId = action.payload['localReservationId'] as String?;
      if (localId != null && cancelledLocals.contains(localId)) {
        return false;
      }
    }
    return true;
  }).toList();
}


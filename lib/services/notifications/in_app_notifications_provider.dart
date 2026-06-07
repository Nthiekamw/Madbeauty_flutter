import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'in_app_notification.dart';
import 'in_app_notifications_sync.dart';

const _prefsKey = 'in_app_notifications.v1';
const _maxItems = 50;

/// Liste des notifications reçues (push + ouverture depuis la barre système).
final inAppNotificationsProvider =
    NotifierProvider<InAppNotificationsNotifier, List<InAppNotification>>(
  InAppNotificationsNotifier.new,
);

final unreadInAppNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(inAppNotificationsProvider).where((e) => !e.read).length;
});

/// Synchronise la boîte de notifications depuis les réservations Supabase.
final inAppNotificationsSyncProvider = FutureProvider.autoDispose<void>((ref) async {
  final synced = await fetchActivityNotifications(ref);
  await ref.read(inAppNotificationsProvider.notifier).mergeSynced(synced);
});

class InAppNotificationsNotifier extends Notifier<List<InAppNotification>> {
  bool _hydrated = false;

  @override
  List<InAppNotification> build() {
    Future.microtask(_hydrateOnce);
    return const [];
  }

  Future<void> _hydrateOnce() async {
    if (_hydrated) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    _hydrated = true;
    if (raw == null || raw.isEmpty) {
      state = const [];
      return;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      state = [
        for (final e in list)
          InAppNotification.fromJson(Map<String, dynamic>.from(e as Map)),
      ];
    } catch (_) {
      state = const [];
    }
  }

  /// Déconnexion : efface les notifications locales (évite tout mélange de compte).
  Future<void> purgeForLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    _hydrated = true;
    state = const [];
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clear() async {
    state = const [];
    await _persist();
  }

  Future<void> markRead(String id) async {
    if (!state.any((e) => e.id == id && !e.read)) return;
    state = [
      for (final n in state) n.id == id ? n.copyWith(read: true) : n,
    ];
    await _persist();
  }

  Future<void> markAllRead() async {
    if (state.isEmpty) return;
    state = [for (final n in state) n.copyWith(read: true)];
    await _persist();
  }

  Future<void> dismiss(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _persist();
  }

  /// Fusionne les alertes issues de l'activité Supabase (réservations).
  Future<void> mergeSynced(List<InAppNotification> incoming) async {
    await _hydrateOnce();
    if (incoming.isEmpty) return;

    final byId = <String, InAppNotification>{
      for (final n in state) n.id: n,
    };
    for (final n in incoming) {
      final existing = byId[n.id];
      byId[n.id] = existing == null
          ? n
          : n.copyWith(read: existing.read || n.read);
    }

    var next = byId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (next.length > _maxItems) {
      next = next.sublist(0, _maxItems);
    }
    state = next;
    await _persist();
  }

  void enqueue(InAppNotification n) {
    if (n.body.trim().isEmpty) return;

    final now = DateTime.now();
    if (state.isNotEmpty) {
      final first = state.first;
      if (first.body == n.body &&
          now.difference(first.createdAt) < const Duration(seconds: 2)) {
        return;
      }
    }

    var next = [n, ...state];
    if (next.length > _maxItems) {
      next = next.sublist(0, _maxItems);
    }
    state = next;
    Future.microtask(_persist);
  }

  void enqueueFromRemoteMessage(RemoteMessage msg) {
    final n = msg.notification;
    final title =
        n?.title ?? (msg.data['title'] as String?) ?? 'MadBeauty';
    var body =
        n?.body ?? (msg.data['body'] as String?) ?? '';
    body = body.trim();
    if (body.isEmpty) return;

    final id = msg.messageId ??
        '${DateTime.now().microsecondsSinceEpoch}_${body.hashCode}';

    final type = msg.data['type'] as String?;
    enqueue(
      InAppNotification(
        id: id,
        title: title.trim().isEmpty ? 'MadBeauty' : title.trim(),
        body: body,
        createdAt: DateTime.now(),
        read: false,
        actionType: type,
        prestataireId: msg.data['prestataire_id'] as String?,
        serviceId: msg.data['service_id'] as String?,
        dateJour: msg.data['date_jour'] as String?,
      ),
    );
  }
}


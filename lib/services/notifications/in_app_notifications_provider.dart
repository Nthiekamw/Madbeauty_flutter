import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'in_app_notification.dart';
import 'in_app_notification_audience.dart';
import 'in_app_notifications_sync.dart';
import '../../features/auth/providers/auth_notifier.dart';

const _prefsKeyPrefix = 'in_app_notifications.v1';
const _dismissedIdsKeyPrefix = 'in_app_notifications_dismissed.v1';
const _legacyPrefsKey = 'in_app_notifications.v1';
const _legacyDismissedIdsKey = 'in_app_notifications_dismissed.v1';
const _maxItems = 50;

String _prefsKeyFor(String userId) => '$_prefsKeyPrefix.$userId';
String _dismissedIdsKeyFor(String userId) =>
    '$_dismissedIdsKeyPrefix.$userId';

/// Liste des notifications reçues (push + ouverture depuis la barre système).
final inAppNotificationsProvider =
    NotifierProvider<InAppNotificationsNotifier, List<InAppNotification>>(
  InAppNotificationsNotifier.new,
);

final unreadInAppNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(inAppNotificationsProvider).where((e) => !e.read).length;
});

/// Notifications filtrées par espace (client / prestataire / admin).
final scopedInAppNotificationsProvider =
    Provider.family<List<InAppNotification>, InAppNotificationAudience>(
  (ref, audience) {
    final all = ref.watch(inAppNotificationsProvider);
    return filterInAppNotificationsForAudience(all, audience);
  },
);

final scopedUnreadInAppNotificationsCountProvider =
    Provider.family<int, InAppNotificationAudience>((ref, audience) {
  return ref
      .watch(scopedInAppNotificationsProvider(audience))
      .where((e) => !e.read)
      .length;
});

/// Synchronise la boîte de notifications depuis les réservations Supabase.
final inAppNotificationsSyncProvider = FutureProvider<void>((ref) async {
  final link = ref.keepAlive();
  ref.onDispose(link.close);

  final userId = ref.read(authNotifierProvider).asData?.value?.id;
  final notifier = ref.read(inAppNotificationsProvider.notifier);
  if (userId != null) {
    await notifier.bindToUser(userId);
  }

  final synced = await fetchActivityNotifications(ref);
  await notifier.mergeSynced(synced);
});

class InAppNotificationsNotifier extends Notifier<List<InAppNotification>> {
  bool _hydrated = false;
  bool _dismissedHydrated = false;
  String? _activeUserId;
  final Set<String> _dismissedIds = {};
  List<InAppNotification> _lastSynced = const [];
  Future<void> _mergeQueue = Future.value();

  static final _reservationNotificationId =
      RegExp(r'^(client|prestataire)_reservation_([0-9a-f-]{36})');

  @override
  List<InAppNotification> build() => const [];

  /// Lie le stockage local au compte connecté (recharge dismiss + liste).
  Future<void> bindToUser(String? userId) async {
    if (_activeUserId == userId) return;

    _activeUserId = userId;
    _hydrated = userId == null;
    _dismissedHydrated = userId == null;
    _dismissedIds.clear();
    _lastSynced = const [];
    state = const [];

    if (userId == null) return;

    await _migrateLegacyPrefsIfNeeded(userId);
    await _hydrateOnce();
    await _hydrateDismissedIds();
  }

  Future<void> _migrateLegacyPrefsIfNeeded(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    final legacyDismissed = prefs.getStringList(_legacyDismissedIdsKey);
    if (legacyDismissed != null && legacyDismissed.isNotEmpty) {
      final userKey = _dismissedIdsKeyFor(userId);
      final existing = prefs.getStringList(userKey) ?? const [];
      await prefs.setStringList(
        userKey,
        {...existing, ...legacyDismissed}.toList(),
      );
      await prefs.remove(_legacyDismissedIdsKey);
    }

    final legacyRaw = prefs.getString(_legacyPrefsKey);
    if (legacyRaw != null && legacyRaw.isNotEmpty) {
      final userKey = _prefsKeyFor(userId);
      if (!prefs.containsKey(userKey)) {
        await prefs.setString(userKey, legacyRaw);
      }
      await prefs.remove(_legacyPrefsKey);
    }
  }

  Future<void> _hydrateDismissedIds() async {
    if (_dismissedHydrated) return;
    final userId = _activeUserId;
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_dismissedIdsKeyFor(userId));
    _dismissedIds
      ..clear()
      ..addAll(raw ?? const []);
    _dismissedHydrated = true;
  }

  Future<void> _persistDismissedIds() async {
    final userId = _activeUserId;
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _dismissedIdsKeyFor(userId),
      _dismissedIds.toList(),
    );
  }

  Future<void> _hydrateOnce() async {
    if (_hydrated) return;
    final userId = _activeUserId;
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKeyFor(userId));
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

  /// Déconnexion : vide la mémoire sans effacer le dismiss persisté du compte.
  Future<void> purgeForLogout() async {
    _activeUserId = null;
    _hydrated = true;
    _dismissedHydrated = true;
    _dismissedIds.clear();
    _lastSynced = const [];
    state = const [];
  }

  Future<void> _persist() async {
    final userId = _activeUserId;
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKeyFor(userId),
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clear() async {
    await _hydrateOnce();
    await _hydrateDismissedIds();
    _rememberDismissed(state);
    _rememberDismissed(_lastSynced);
    state = const [];
    await _persist();
    await _persistDismissedIds();
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

  Future<void> markAllReadForAudience(InAppNotificationAudience audience) async {
    await _hydrateOnce();
    if (state.isEmpty) return;
    state = [
      for (final n in state)
        if (inAppNotificationMatchesAudience(n, audience))
          n.copyWith(read: true)
        else
          n,
    ];
    await _persist();
  }

  Future<void> clearForAudience(InAppNotificationAudience audience) async {
    await _hydrateOnce();
    await _hydrateDismissedIds();
    final removed = state
        .where((e) => inAppNotificationMatchesAudience(e, audience))
        .toList();
    _rememberDismissed(removed);
    _rememberDismissed(
      _lastSynced.where((e) => inAppNotificationMatchesAudience(e, audience)),
    );
    state = [
      for (final n in state)
        if (!inAppNotificationMatchesAudience(n, audience)) n,
    ];
    await _persist();
    await _persistDismissedIds();
  }

  Future<void> dismiss(String id) async {
    await _hydrateDismissedIds();
    final fromState = state.where((e) => e.id == id);
    if (fromState.isNotEmpty) {
      _rememberDismissed(fromState);
    } else {
      _dismissedIds.add(id);
    }
    state = state.where((e) => e.id != id).toList();
    await _persist();
    await _persistDismissedIds();
  }

  /// Fusionne les alertes issues de l'activité Supabase (réservations).
  Future<void> mergeSynced(List<InAppNotification> incoming) {
    _mergeQueue = _mergeQueue.then((_) => _mergeSynced(incoming));
    return _mergeQueue;
  }

  Future<void> _mergeSynced(List<InAppNotification> incoming) async {
    if (_activeUserId == null) return;
    await _hydrateOnce();
    await _hydrateDismissedIds();
    _lastSynced = incoming;
    if (incoming.isEmpty) return;

    final filtered = incoming.where((n) => !_isDismissed(n)).toList();
    if (filtered.isEmpty && state.isEmpty) return;

    final byId = <String, InAppNotification>{
      for (final n in state) n.id: n,
    };
    for (final n in filtered) {
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

  void _rememberDismissed(Iterable<InAppNotification> notifications) {
    for (final notification in notifications) {
      _dismissedIds.addAll(_dismissalKeysFor(notification));
    }
  }

  Set<String> _dismissalKeysFor(InAppNotification notification) {
    final keys = <String>{notification.id};
    final reservationId =
        notification.reservationId ?? notification.bookingId;
    if (reservationId != null) {
      keys.add('reservation:$reservationId');
    }

    final match = _reservationNotificationId.firstMatch(notification.id);
    if (match != null) {
      keys.add('${match.group(1)}_reservation_${match.group(2)}');
    }
    return keys;
  }

  bool _isDismissed(InAppNotification notification) {
    final keys = _dismissalKeysFor(notification);
    for (final key in keys) {
      if (_dismissedIds.contains(key)) return true;
    }
    for (final dismissed in _dismissedIds) {
      for (final key in keys) {
        if (dismissed.startsWith(key)) return true;
      }
    }
    return false;
  }

  void enqueue(InAppNotification n) {
    if (n.body.trim().isEmpty) return;
    if (_activeUserId == null) return;

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
    final reservationId = msg.data['reservation_id'] as String? ??
        msg.data['reservationId'] as String?;
    final pushRole = msg.data['role'] as String?;
    final supportThreadId = msg.data['thread_id'] as String?;
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
        reservationId: reservationId,
        bookingId: msg.data['booking_id'] as String? ??
            msg.data['bookingId'] as String?,
        role: pushRole,
        audience: msg.data['audience'] as String? ??
            InAppNotificationAudienceX.parse(pushRole)?.wire ??
            _audienceWireFromPushType(type, pushRole),
        nav: msg.data['nav'] as String?,
        bugReportId: msg.data['bug_report_id'] as String?,
        threadId: supportThreadId,
      ),
    );
  }
}

String? _audienceWireFromPushType(String? type, String? role) {
  return switch (type) {
    'booking_created' => InAppNotificationAudience.prestataire.wire,
    'prestataire_like' ||
    'prestataire_review' ||
    'prestataire_catalog_visibility' ||
    'prestataire_profile_incomplete' ||
    'prestataire_map_missing' ||
    'prestataire_verification_approved' ||
    'prestataire_verification_revoked' =>
      InAppNotificationAudience.prestataire.wire,
    'booking_status' || 'slot_waitlist' =>
      InAppNotificationAudienceX.parse(role)?.wire ??
          InAppNotificationAudience.client.wire,
    'message' =>
      InAppNotificationAudienceX.parse(role)?.wire ??
          InAppNotificationAudience.client.wire,
    'bug_report' => InAppNotificationAudience.admin.wire,
    'user_support_message' =>
      InAppNotificationAudienceX.parse(role)?.wire ??
          InAppNotificationAudience.client.wire,
    _ => InAppNotificationAudienceX.parse(role)?.wire,
  };
}


import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/storage/local_cache_service.dart';
import '../models/client_home_layout.dart';
import '../models/client_home_section_id.dart';
import '../providers/home_feed_provider.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/providers/auth_notifier.dart';

class ClientHomeLayoutNotifier extends Notifier<ClientHomeLayout> {
  @override
  ClientHomeLayout build() {
    final raw = LocalCacheService.instance.clientHomeLayoutJson;
    final layout = _layoutFromCache(raw);

    if (_shouldMigrateLayout(raw, layout)) {
      final defaults = ClientHomeLayout.defaults;
      Future.microtask(() => _persist(defaults));
      return defaults;
    }

    return layout;
  }

  ClientHomeLayout _layoutFromCache(String? raw) {
    if (raw == null || raw.trim().isEmpty) return ClientHomeLayout.defaults;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return ClientHomeLayout.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    } catch (_) {}
    return ClientHomeLayout.defaults;
  }

  bool _shouldMigrateLayout(String? raw, ClientHomeLayout layout) {
    if (raw == null || raw.trim().isEmpty) return false;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return true;
      final map = Map<String, dynamic>.from(decoded);
      final version = map['version'] as int? ?? 1;
      if (version != ClientHomeLayout.layoutVersion) return true;

      final order = layout.order;
      if (!order.contains(ClientHomeSectionId.promo)) return true;
      if (order.isNotEmpty &&
          order.first == ClientHomeSectionId.nextAppointment) {
        return true;
      }
      if (order.length >= 2 &&
          order[1] == ClientHomeSectionId.promo &&
          !order.contains(ClientHomeSectionId.nextAppointment)) {
        return true;
      }
    } catch (_) {
      return true;
    }

    return false;
  }

  Future<void> _persist(ClientHomeLayout layout) async {
    await LocalCacheService.instance.setClientHomeLayoutJson(
      jsonEncode(layout.toJson()),
    );
  }

  Future<void> reorderVisible(
    List<ClientHomeSectionId> visible, {
    required int oldIndex,
    required int newIndex,
  }) async {
    final next = state.reorderVisible(
      visible,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
    state = next;
    await _persist(next);
  }
}

final clientHomeLayoutProvider =
    NotifierProvider<ClientHomeLayoutNotifier, ClientHomeLayout>(
  ClientHomeLayoutNotifier.new,
);

List<ClientHomeSectionId> visibleClientHomeSections({
  required ClientHomeLayout layout,
  required bool isLoggedIn,
  required bool hasSupabase,
  required bool hasFeedSelection,
}) {
  final out = <ClientHomeSectionId>[];
  for (final id in layout.order) {
    switch (id) {
      case ClientHomeSectionId.nextAppointment:
        if (isLoggedIn && hasSupabase) out.add(id);
      case ClientHomeSectionId.inspiration:
        out.add(id);
      case ClientHomeSectionId.promo:
        out.add(id);
      case ClientHomeSectionId.feed:
        if (hasSupabase && hasFeedSelection) out.add(id);
      case ClientHomeSectionId.nearby:
        if (hasSupabase) out.add(id);
      case ClientHomeSectionId.topRated:
        if (hasSupabase) out.add(id);
    }
  }
  return out;
}

List<ClientHomeSectionId> layoutSheetClientHomeSections({
  required ClientHomeLayout layout,
  required bool isLoggedIn,
  required bool hasSupabase,
}) {
  final out = <ClientHomeSectionId>[];
  for (final id in layout.order) {
    switch (id) {
      case ClientHomeSectionId.nextAppointment:
        if (isLoggedIn && hasSupabase) out.add(id);
      case ClientHomeSectionId.inspiration:
        out.add(id);
      case ClientHomeSectionId.promo:
        out.add(id);
      case ClientHomeSectionId.feed:
        if (hasSupabase) out.add(id);
      case ClientHomeSectionId.nearby:
        if (hasSupabase) out.add(id);
      case ClientHomeSectionId.topRated:
        if (hasSupabase) out.add(id);
    }
  }
  return out;
}

/// Helpers pour [ClientHomeReorderableSections].
bool clientHomeIsLoggedIn(WidgetRef ref) {
  final user = ref.watch(authNotifierProvider).asData?.value;
  final isGuest = ref.watch(isGuestBrowsingProvider);
  return user != null && !isGuest;
}

bool clientHomeHasFeedSelection(WidgetRef ref) {
  final selection = ref.watch(homeFeedSelectionProvider);
  return selection?.showsFeedSection ?? false;
}

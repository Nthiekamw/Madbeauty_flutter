import 'dart:convert';

import 'local_cache_service.dart';

/// Réservations pour lesquelles l'invite à noter a déjà été affichée ou ignorée.
class ReviewPromptStore {
  ReviewPromptStore._();

  static const _legacyKey = 'reviews.prompt_handled_booking_ids';
  static const _keyPrefix = 'reviews.prompt_handled_booking_ids';

  static ReviewPromptStore? _instance;
  static ReviewPromptStore get instance =>
      _instance ??= ReviewPromptStore._();

  String? _activeUserId;

  String? _storageKeyFor(String userId) => '$_keyPrefix.$userId';

  /// Lie le cache local au compte connecté.
  Future<void> bindToUser(String? userId) async {
    if (_activeUserId == userId) return;
    _activeUserId = userId;
    if (userId == null) return;
    await _migrateLegacyIfNeeded(userId);
  }

  Future<void> _migrateLegacyIfNeeded(String userId) async {
    final legacy = LocalCacheService.instance.getString(_legacyKey);
    if (legacy == null || legacy.isEmpty) return;

    final userKey = _storageKeyFor(userId)!;
    final existing = LocalCacheService.instance.getString(userKey);
    if (existing == null || existing.isEmpty) {
      await LocalCacheService.instance.setString(userKey, legacy);
    }
    await LocalCacheService.instance.remove(_legacyKey);
  }

  Set<String> get handledBookingIds {
    final userId = _activeUserId;
    if (userId == null) return {};

    final raw = LocalCacheService.instance.getString(_storageKeyFor(userId)!);
    if (raw == null || raw.isEmpty) return {};
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> markHandled(String bookingId) async {
    final userId = _activeUserId;
    if (userId == null) return;

    final set = handledBookingIds..add(bookingId);
    await LocalCacheService.instance.setString(
      _storageKeyFor(userId)!,
      jsonEncode(set.toList()),
    );
  }

  Future<void> clearForUser(String userId) async {
    await LocalCacheService.instance.remove(_storageKeyFor(userId)!);
  }
}

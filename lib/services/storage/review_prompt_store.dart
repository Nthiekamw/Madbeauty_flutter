import 'dart:convert';

import 'local_cache_service.dart';

/// Réservations pour lesquelles l'invite à noter a déjà été affichée ou ignorée.
class ReviewPromptStore {
  ReviewPromptStore._();

  static const _key = 'reviews.prompt_handled_booking_ids';

  static ReviewPromptStore? _instance;
  static ReviewPromptStore get instance =>
      _instance ??= ReviewPromptStore._();

  Set<String> get handledBookingIds {
    final raw = LocalCacheService.instance.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> markHandled(String bookingId) async {
    final set = handledBookingIds..add(bookingId);
    await LocalCacheService.instance.setString(
      _key,
      jsonEncode(set.toList()),
    );
  }

  Future<void> clear() async {
    await LocalCacheService.instance.remove(_key);
  }
}


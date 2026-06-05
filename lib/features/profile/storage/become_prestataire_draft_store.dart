import 'dart:convert';

import '../../../services/storage/local_cache_service.dart';
import '../logic/become_prestataire_draft.dart';

/// Persistance locale du parcours « Devenir prestataire ».
class BecomePrestataireDraftStore {
  BecomePrestataireDraftStore._();

  static const String _key = 'profile.become_prestataire_draft';

  static BecomePrestataireDraftStore get instance =>
      BecomePrestataireDraftStore._();

  bool get hasDraft {
    final draft = read();
    return draft != null && draft.isActive;
  }

  BecomePrestataireDraft? read() {
    final raw = LocalCacheService.instance.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return BecomePrestataireDraft.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(BecomePrestataireDraft draft) async {
    if (!draft.isActive) {
      await clear();
      return;
    }
    await LocalCacheService.instance.setString(
      _key,
      jsonEncode(draft.toJson()),
    );
  }

  Future<void> clear() => LocalCacheService.instance.remove(_key);
}


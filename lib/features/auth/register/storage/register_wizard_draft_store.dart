import 'dart:convert';

import '../../../../services/storage/local_cache_service.dart';
import '../logic/register_wizard_draft.dart';

/// Persistance SharedPreferences du brouillon d’inscription.
class RegisterWizardDraftStore {
  RegisterWizardDraftStore._();

  static const String _key = 'auth.register_wizard_draft';

  static RegisterWizardDraftStore get instance => RegisterWizardDraftStore._();

  bool get hasDraft => read() != null;

  RegisterWizardDraft? read() {
    final raw = LocalCacheService.instance.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return RegisterWizardDraft.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  Future<void> save(RegisterWizardDraft draft) async {
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

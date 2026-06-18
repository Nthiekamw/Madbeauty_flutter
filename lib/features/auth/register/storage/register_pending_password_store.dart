import 'dart:convert';

import '../../../../services/storage/local_cache_service.dart';

/// Mot de passe d'inscription conservé brièvement pendant la confirmation e-mail.
///
/// Jamais écrit dans [RegisterWizardDraft] ; effacé dès que la session est ouverte.
class RegisterPendingPasswordStore {
  RegisterPendingPasswordStore._();

  static const _key = 'auth.register_pending_password_v1';

  static RegisterPendingPasswordStore get instance =>
      RegisterPendingPasswordStore._();

  Future<void> save({
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || password.isEmpty) return;
    await LocalCacheService.instance.setString(
      _key,
      jsonEncode({'email': normalized, 'password': password}),
    );
  }

  String? readForEmail(String email) {
    final raw = LocalCacheService.instance.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      final storedEmail = (map['email'] as String?)?.trim().toLowerCase() ?? '';
      if (storedEmail != email.trim().toLowerCase()) return null;
      return map['password'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() => LocalCacheService.instance.remove(_key);
}

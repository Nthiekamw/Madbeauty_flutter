import '../../../../core/models/user_role.dart';
import '../../../../services/storage/local_cache_service.dart';
import '../logic/register_wizard_draft.dart';

/// Intent client/prestataire choisi à l’inscription (avant sync serveur).
abstract final class RegisterWizardRoleIntent {
  RegisterWizardRoleIntent._();

  static Future<void> persist(UserRole role) async {
    await LocalCacheService.instance.setSelectedRole(role.value);
    await LocalCacheService.instance.setSignupShellRole(role.value);
  }

  static Future<void> persistFromDraft(RegisterWizardDraft draft) async {
    final role = draft.role;
    if (role != null) {
      await persist(role);
    }
  }
}

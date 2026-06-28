import '../../../core/models/user_role.dart';
import '../../../features/profile/logic/become_prestataire_flow_resume.dart';
import '../../../features/profile/storage/become_prestataire_draft_store.dart';
import '../../../features/auth/register/storage/register_wizard_draft_store.dart';
import '../../../router/app_router.dart';
import '../../../services/storage/local_cache_service.dart';

/// Rôles serveur mis en cache pour le redirect GoRouter (lecture synchrone).
abstract final class AuthRoleCache {
  AuthRoleCache._();

  /// Persiste les rôles Supabase et recadre [selectedRole] si invalide.
  ///
  /// Ne remplace pas un [selectedRole] déjà valide côté serveur : c'est le
  /// dernier espace actif (client / prestataire) choisi par l'utilisateur.
  static Future<void> persistServerRoles(List<UserRole> roles) async {
    final values = roles.map((r) => r.value).toList();
    await LocalCacheService.instance.setCachedServerRoles(values);

    final lastActiveShell = LocalCacheService.instance.selectedRole;
    if (lastActiveShell != null && values.contains(lastActiveShell)) {
      return;
    }

    final effective = resolveEffectiveRole(
      serverRoleValues: values,
      cachedRole: lastActiveShell,
    );

    if (effective != null) {
      await LocalCacheService.instance.setSelectedRole(effective);
    } else if (!_keepCachedRoleOnAmbiguousRoles()) {
      await LocalCacheService.instance.clearSelectedRole();
    }
  }

  static bool _keepCachedRoleOnAmbiguousRoles() {
    final cache = LocalCacheService.instance;
    final last = cache.selectedRole;
    if (last == 'client' || last == 'prestataire') return true;
    if (cache.signupShellRole == 'prestataire') return true;
    if (BecomePrestataireDraftStore.instance.hasDraft) return true;
    return false;
  }

  static String? resolveEffectiveRole({
    required List<String> serverRoleValues,
    String? cachedRole,
  }) {
    if (serverRoleValues.contains('admin')) {
      return 'admin';
    }

    final signupIntent = LocalCacheService.instance.signupShellRole;

    if (serverRoleValues.isEmpty) {
      return cachedRole ?? signupIntent;
    }

    if (cachedRole == 'prestataire' &&
        serverRoleValues.contains('prestataire')) {
      return 'prestataire';
    }
    if (cachedRole == 'client' && serverRoleValues.contains('client')) {
      return 'client';
    }

    // Choix explicite (inscription) pas encore visible côté serveur.
    if (cachedRole != null && !serverRoleValues.contains(cachedRole)) {
      return cachedRole;
    }

    if (signupIntent == 'prestataire' &&
        !serverRoleValues.contains('prestataire')) {
      return 'prestataire';
    }

    if (serverRoleValues.length > 1) {
      if (cachedRole != null && serverRoleValues.contains(cachedRole)) {
        return cachedRole;
      }
      if (signupIntent != null && serverRoleValues.contains(signupIntent)) {
        return signupIntent;
      }
      if (BecomePrestataireDraftStore.instance.hasDraft) {
        return 'prestataire';
      }
      return cachedRole ?? signupIntent;
    }

    if (serverRoleValues.length == 1) {
      final only = serverRoleValues.first;
      if (only == 'client' && signupIntent == 'prestataire') {
        return 'prestataire';
      }
      return only;
    }
    return null;
  }

  static bool hasAdminAmong(List<String> serverRoleValues) =>
      serverRoleValues.contains('admin');

  /// Vérifie complétion profil prestataire au bootstrap (splash) uniquement si
  /// l'utilisateur est routé vers l'espace prestataire.
  static bool shouldBootstrapPrestataireProfile() {
    final cachedRoles = LocalCacheService.instance.cachedServerRoles;

    if (!cachedRoles.contains('prestataire') &&
        BecomePrestataireDraftStore.instance.hasDraft) {
      return true;
    }

    final effective = resolveEffectiveRole(
      serverRoleValues: cachedRoles,
      cachedRole: LocalCacheService.instance.selectedRole,
    );
    return effective == 'prestataire';
  }

  /// Chemin shell pour un utilisateur connecté (sync, pour [GoRouter.redirect]).
  static String preferredAuthenticatedPath() {
    final cachedRoles = LocalCacheService.instance.cachedServerRoles;
    final serverHasPrestataire = cachedRoles.contains('prestataire');

    if (!serverHasPrestataire) {
      final resume = BecomePrestataireFlowResume.pathAfterAuthBootstrap();
      if (resume != null) return resume;
    }

    if (hasAdminAmong(cachedRoles)) {
      return AppRoutes.adminHome;
    }

    final registerDraft = RegisterWizardDraftStore.instance.read();
    if (registerDraft?.role != null && cachedRoles.isEmpty) {
      final intent = registerDraft!.role!.value;
      return switch (intent) {
        'prestataire' => AppRoutes.prestataireDashboard,
        'client' => AppRoutes.clientHome,
        _ => AppRoutes.clientHome,
      };
    }

    final effective = resolveEffectiveRole(
      serverRoleValues: cachedRoles,
      cachedRole: LocalCacheService.instance.selectedRole,
    );

    if (!serverHasPrestataire) {
      final becomeDraft = BecomePrestataireDraftStore.instance.read();
      if (becomeDraft != null &&
          becomeDraft.step1Submitted &&
          becomeDraft.step2Started &&
          (effective == 'prestataire' ||
              LocalCacheService.instance.signupShellRole == 'prestataire')) {
        return AppRoutes.prestataireProfileEdit;
      }
    }

    return switch (effective) {
      'admin' => AppRoutes.adminHome,
      'prestataire' => AppRoutes.prestataireDashboard,
      'client' => AppRoutes.clientHome,
      // Rôles pas encore synchronisés : éviter /splash (conflit avec PostAuthNavigation).
      null when cachedRoles.isEmpty => AppRoutes.role,
      _ => AppRoutes.role,
    };
  }

  static String? preferredAuthenticatedRole() {
    return resolveEffectiveRole(
      serverRoleValues: LocalCacheService.instance.cachedServerRoles,
      cachedRole: LocalCacheService.instance.selectedRole,
    );
  }
}


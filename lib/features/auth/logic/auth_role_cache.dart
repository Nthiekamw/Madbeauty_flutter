import '../../../core/models/user_role.dart';
import '../../../router/app_router.dart';
import '../../../services/storage/local_cache_service.dart';

/// Rôles serveur mis en cache pour le redirect GoRouter (lecture synchrone).
abstract final class AuthRoleCache {
  AuthRoleCache._();

  /// Persiste les rôles Supabase et recadre [selectedRole] si invalide.
  static Future<void> persistServerRoles(List<UserRole> roles) async {
    final values = roles.map((r) => r.value).toList();
    await LocalCacheService.instance.setCachedServerRoles(values);

    final effective = resolveEffectiveRole(
      serverRoleValues: values,
      cachedRole: LocalCacheService.instance.selectedRole,
    );

    if (effective != null) {
      await LocalCacheService.instance.setSelectedRole(effective);
    } else if (LocalCacheService.instance.selectedRole != null) {
      await LocalCacheService.instance.clearSelectedRole();
    }
  }

  static String? resolveEffectiveRole({
    required List<String> serverRoleValues,
    String? cachedRole,
  }) {
    if (serverRoleValues.isEmpty) return null;

    if (cachedRole == 'prestataire' &&
        serverRoleValues.contains('prestataire')) {
      return 'prestataire';
    }
    if (cachedRole == 'client' && serverRoleValues.contains('client')) {
      return 'client';
    }
    if (serverRoleValues.length == 1) {
      return serverRoleValues.first;
    }
    return null;
  }

  /// Chemin shell pour un utilisateur connecté (sync, pour [GoRouter.redirect]).
  static String preferredAuthenticatedPath() {
    final effective = resolveEffectiveRole(
      serverRoleValues: LocalCacheService.instance.cachedServerRoles,
      cachedRole: LocalCacheService.instance.selectedRole,
    );
    return switch (effective) {
      'prestataire' => AppRoutes.prestataireDashboard,
      'client' => AppRoutes.clientHome,
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

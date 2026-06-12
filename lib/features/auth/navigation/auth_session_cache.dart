import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_role.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../../services/supabase/profile/client_profile_providers.dart';
import '../../../services/supabase/profile/profile_service.dart';
import '../../../services/supabase/supabase_service.dart';
import '../../prestataire/providers/profile/current_prestataire_provider.dart';
import '../logic/auth_role_cache.dart';
import '../providers/auth_notifier.dart';
import '../providers/my_roles_provider.dart';

/// Met en cache rôles / rôle sélectionné avant un redirect GoRouter (sans `go()`).
abstract final class AuthSessionCache {
  AuthSessionCache._();

  /// `false` si l'utilisateur est banni (déconnexion effectuée).
  static Future<bool> prepareForAuthenticatedRedirect(
    ProviderContainer container,
  ) async {
    final user = container.read(authNotifierProvider).value;
    if (user == null) return false;

    final banStatus =
        await ProfileService(SupabaseService.client).getBanStatus(user.id);
    if (banStatus.isBanned) {
      await container.read(authNotifierProvider.notifier).signOut();
      return false;
    }

    final roles = await container.read(myRolesProvider.future);
    await AuthRoleCache.persistServerRoles(roles);

    if (roles.any((r) => r == UserRole.admin)) {
      await LocalCacheService.instance.setSelectedRole('admin');
      return true;
    }

    if (roles.isEmpty) {
      final inferred = await _inferRole(container);
      if (inferred != null) {
        await LocalCacheService.instance.setSelectedRole(inferred);
        return true;
      }
      final pending = LocalCacheService.instance.selectedRole;
      if (pending == 'prestataire' || pending == 'client') {
        return true;
      }
      return true;
    }

    final effective = AuthRoleCache.resolveEffectiveRole(
      serverRoleValues: roles.map((r) => r.value).toList(),
      cachedRole: LocalCacheService.instance.selectedRole,
    );
    if (effective == null) {
      final inferred = await _inferRole(container);
      if (inferred != null) {
        await LocalCacheService.instance.setSelectedRole(inferred);
      }
      return true;
    }

    await LocalCacheService.instance.setSelectedRole(effective);
    return true;
  }

  static Future<String?> _inferRole(ProviderContainer container) async {
    final client = await container.read(currentClientProfileProvider.future);
    final presta = await container.read(currentPrestataireProvider.future);
    if (client != null && presta == null) return 'client';
    if (presta != null && client == null) return 'prestataire';
    return null;
  }
}

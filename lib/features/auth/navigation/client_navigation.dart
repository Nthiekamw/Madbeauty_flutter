import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../router/navigation_extensions.dart';
import '../../../services/auth/role_service.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../../core/models/user_role.dart';
import '../logic/auth_role_cache.dart';
import '../providers/my_roles_provider.dart';

/// Navigation vers l'espace client.
abstract final class ClientNavigation {
  ClientNavigation._();

  static Future<void> switchToClientSpace(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final rolesService = RoleService.fromEnv();
      await rolesService.ensureRole(UserRole.client);
      ref.invalidate(myRolesProvider);
    } catch (_) {
      // Continuer la bascule même si ensureRole échoue (hors ligne).
    }
    final roles = await ref.read(myRolesProvider.future);
    await AuthRoleCache.persistServerRoles(roles);
    await LocalCacheService.instance.setSelectedRole('client');
    await LocalCacheService.instance.setSignupShellRole('client');
    if (!context.mounted) return;
    context.goHome();
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../router/navigation_extensions.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../prestataire/navigation/prestataire_navigation.dart';
import '../logic/auth_role_cache.dart';
import '../providers/my_roles_provider.dart';

/// Destination après connexion, inscription ou splash (rôles serveur + cache).
abstract final class PostAuthNavigation {
  PostAuthNavigation._();

  static Future<String?> resolveEffectiveRole(WidgetRef ref) async {
    final roles = await ref.read(myRolesProvider.future);
    await AuthRoleCache.persistServerRoles(roles);
    return AuthRoleCache.resolveEffectiveRole(
      serverRoleValues: roles.map((r) => r.value).toList(),
      cachedRole: LocalCacheService.instance.selectedRole,
    );
  }

  static Future<String?> resolveEffectiveRoleWithContainer(
    ProviderContainer container,
  ) async {
    final roles = await container.read(myRolesProvider.future);
    await AuthRoleCache.persistServerRoles(roles);
    return AuthRoleCache.resolveEffectiveRole(
      serverRoleValues: roles.map((r) => r.value).toList(),
      cachedRole: LocalCacheService.instance.selectedRole,
    );
  }

  /// Après login ou inscription client.
  static Future<void> navigate(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;

    final roles = await ref.read(myRolesProvider.future);
    await AuthRoleCache.persistServerRoles(roles);
    if (!context.mounted) return;

    if (roles.isEmpty) {
      context.goRoleChoice();
      return;
    }

    final effective = AuthRoleCache.resolveEffectiveRole(
      serverRoleValues: roles.map((r) => r.value).toList(),
      cachedRole: LocalCacheService.instance.selectedRole,
    );
    if (!context.mounted) return;

    if (effective == null) {
      context.goRoleChoice();
      return;
    }

    await LocalCacheService.instance.setSelectedRole(effective);
    if (!context.mounted) return;

    if (effective == 'prestataire') {
      await PrestataireNavigation.switchToPrestataireSpace(context, ref);
    } else {
      context.goHome();
    }
  }

  /// Splash / cold start : même logique, sans [WidgetRef].
  static Future<void> navigateWithContainer(
    BuildContext context,
    ProviderContainer container,
  ) async {
    if (!context.mounted) return;

    final roles = await container.read(myRolesProvider.future);
    await AuthRoleCache.persistServerRoles(roles);
    if (!context.mounted) return;

    if (roles.isEmpty) {
      context.goRoleChoice();
      return;
    }

    final effective = AuthRoleCache.resolveEffectiveRole(
      serverRoleValues: roles.map((r) => r.value).toList(),
      cachedRole: LocalCacheService.instance.selectedRole,
    );
    if (!context.mounted) return;

    if (effective == null) {
      context.goRoleChoice();
      return;
    }

    await LocalCacheService.instance.setSelectedRole(effective);
    if (!context.mounted) return;

    if (effective == 'prestataire') {
      await PrestataireNavigation.switchToPrestataireSpaceWithContainer(
        context,
        container,
      );
    } else {
      context.goHome();
    }
  }
}

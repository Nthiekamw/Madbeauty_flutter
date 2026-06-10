import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/navigation_extensions.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../prestataire/navigation/prestataire_navigation.dart';
import '../../profile/logic/become_prestataire_flow_resume.dart';
import '../../prestataire/providers/profile/current_prestataire_provider.dart';
import '../../../core/models/user_role.dart';
import '../logic/auth_role_cache.dart';
import '../providers/auth_notifier.dart';
import '../providers/my_roles_provider.dart';
import '../../../services/supabase/profile/client_profile_providers.dart';
import '../../../services/supabase/profile/profile_service.dart';
import '../../../services/supabase/supabase_service.dart';

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
  static Future<void> navigate(BuildContext context, WidgetRef ref) {
    return navigateWithContainer(context, ref.container);
  }

  /// Splash / cold start : même logique, sans [WidgetRef].
  static Future<void> navigateWithContainer(
    BuildContext context,
    ProviderContainer container,
  ) async {
    if (!context.mounted) return;

    if (await _redirectIfBannedWithContainer(context, container)) return;

    final becomeResume = BecomePrestataireFlowResume.pathAfterAuthBootstrap();
    if (becomeResume != null) {
      if (BecomePrestataireFlowResume.needsPrestataireRole) {
        await LocalCacheService.instance.setSelectedRole('prestataire');
      }
      if (!context.mounted) return;
      context.go(becomeResume);
      return;
    }

    final roles = await container.read(myRolesProvider.future);
    await AuthRoleCache.persistServerRoles(roles);
    if (!context.mounted) return;

    if (roles.any((r) => r == UserRole.admin)) {
      await LocalCacheService.instance.setSelectedRole('admin');
      context.goAdminHome();
      return;
    }

    if (roles.isEmpty) {
      final inferredRole = await _inferRoleFromProfilesWithContainer(container);
      if (inferredRole != null) {
        await LocalCacheService.instance.setSelectedRole(inferredRole);
        if (!context.mounted) return;
        if (inferredRole == 'prestataire') {
          await PrestataireNavigation.switchToPrestataireSpaceWithContainer(
            context,
            container,
          );
        } else {
          context.goHome();
        }
        return;
      }
      final pending = LocalCacheService.instance.selectedRole;
      if (pending == 'prestataire') {
        await PrestataireNavigation.switchToPrestataireSpaceWithContainer(
          context,
          container,
        );
        return;
      }
      if (pending == 'client') {
        context.goHome();
        return;
      }
      context.goRoleChoice();
      return;
    }

    final effective = AuthRoleCache.resolveEffectiveRole(
      serverRoleValues: roles.map((r) => r.value).toList(),
      cachedRole: LocalCacheService.instance.selectedRole,
    );
    if (!context.mounted) return;

    if (effective == null) {
      final inferredRole = await _inferRoleFromProfilesWithContainer(container);
      if (inferredRole != null) {
        await LocalCacheService.instance.setSelectedRole(inferredRole);
        if (!context.mounted) return;
        if (inferredRole == 'prestataire') {
          await PrestataireNavigation.switchToPrestataireSpaceWithContainer(
            context,
            container,
          );
        } else {
          context.goHome();
        }
        return;
      }
      context.goRoleChoice();
      return;
    }

    await LocalCacheService.instance.setSelectedRole(effective);
    if (!context.mounted) return;

    if (effective == 'admin') {
      context.goAdminHome();
    } else if (effective == 'prestataire') {
      await PrestataireNavigation.switchToPrestataireSpaceWithContainer(
        context,
        container,
      );
    } else {
      context.goHome();
    }
  }

  static Future<bool> _redirectIfBannedWithContainer(
    BuildContext context,
    ProviderContainer container,
  ) async {
    final user = container.read(authNotifierProvider).value;
    if (user == null) return false;
    final banned = await ProfileService(SupabaseService.client)
        .isUserBanned(user.id);
    if (!banned) return false;
    await container.read(authNotifierProvider.notifier).signOut();
    if (context.mounted) context.goWelcome();
    return true;
  }

  static Future<String?> _inferRoleFromProfilesWithContainer(
    ProviderContainer container,
  ) async {
    final client = await container.read(currentClientProfileProvider.future);
    final presta = await container.read(currentPrestataireProvider.future);
    if (client != null && presta == null) return 'client';
    if (presta != null && client == null) return 'prestataire';
    return null;
  }
}


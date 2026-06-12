import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_router.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../prestataire/navigation/prestataire_navigation.dart';
import '../../profile/logic/become_prestataire_flow_resume.dart';
import '../../prestataire/providers/profile/current_prestataire_provider.dart';
import '../../../core/models/user_role.dart';
import '../logic/account_ban_handler.dart';
import '../logic/auth_role_cache.dart';
import '../providers/my_roles_provider.dart';
import '../../../services/supabase/profile/client_profile_providers.dart';

/// Destination après connexion, inscription ou splash (rôles serveur + cache).
abstract final class PostAuthNavigation {
  PostAuthNavigation._();

  static bool _navigationInFlight = false;

  /// Bloque [appRouterRedirect] pendant une navigation manuelle post-login.
  static bool get isInFlight => _navigationInFlight;

  static GoRouter _router(ProviderContainer container) =>
      container.read(goRouterProvider);

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
  static Future<void> navigate(WidgetRef ref) {
    return navigateWithContainer(ref.container);
  }

  /// Splash / cold start / login : navigation post-auth via [GoRouter] uniquement.
  static Future<void> navigateWithContainer(ProviderContainer container) async {
    if (_navigationInFlight) return;
    _navigationInFlight = true;
    try {
      final target = await resolveDestinationPath(container);
      if (target != null) {
        await _router(container).goDeferred(target);
      }
      await _waitForRouterToSettle();
    } finally {
      _navigationInFlight = false;
    }
  }

  /// Résout la destination post-auth sans naviguer (handoff redirect).
  static Future<String?> resolveDestinationPath(
    ProviderContainer container,
  ) async {
    return _resolveDestinationPath(container);
  }

  static Future<void> _waitForRouterToSettle() async {
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!completer.isCompleted) completer.complete();
      });
    });
    return completer.future;
  }

  static Future<String?> _resolveDestinationPath(
    ProviderContainer container,
  ) async {
    final router = _router(container);

    if (await _redirectIfBannedWithContainer(router, container)) return null;

    final becomeResume = BecomePrestataireFlowResume.pathAfterAuthBootstrap();
    if (becomeResume != null) {
      if (BecomePrestataireFlowResume.needsPrestataireRole) {
        await LocalCacheService.instance.setSelectedRole('prestataire');
      }
      return becomeResume;
    }

    final roles = await container.read(myRolesProvider.future);
    await AuthRoleCache.persistServerRoles(roles);

    if (roles.any((r) => r == UserRole.admin)) {
      await LocalCacheService.instance.setSelectedRole('admin');
      return AppRoutes.adminHome;
    }

    if (roles.isEmpty) {
      final inferredRole = await _inferRoleFromProfilesWithContainer(container);
      if (inferredRole != null) {
        await LocalCacheService.instance.setSelectedRole(inferredRole);
        if (inferredRole == 'prestataire') {
          return PrestataireNavigation.prestataireSpacePath(container);
        }
        return AppRoutes.clientHome;
      }
      final pending = LocalCacheService.instance.selectedRole;
      if (pending == 'prestataire') {
        return PrestataireNavigation.prestataireSpacePath(container);
      }
      if (pending == 'client') {
        return AppRoutes.clientHome;
      }
      return AppRoutes.role;
    }

    final effective = AuthRoleCache.resolveEffectiveRole(
      serverRoleValues: roles.map((r) => r.value).toList(),
      cachedRole: LocalCacheService.instance.selectedRole,
    );

    if (effective == null) {
      final inferredRole = await _inferRoleFromProfilesWithContainer(container);
      if (inferredRole != null) {
        await LocalCacheService.instance.setSelectedRole(inferredRole);
        if (inferredRole == 'prestataire') {
          return PrestataireNavigation.prestataireSpacePath(container);
        }
        return AppRoutes.clientHome;
      }
      return AppRoutes.role;
    }

    await LocalCacheService.instance.setSelectedRole(effective);

    return switch (effective) {
      'admin' => AppRoutes.adminHome,
      'prestataire' => PrestataireNavigation.prestataireSpacePath(container),
      _ => AppRoutes.clientHome,
    };
  }

  static Future<bool> _redirectIfBannedWithContainer(
    GoRouter router,
    ProviderContainer container,
  ) async {
    final allowed = await AccountBanHandler.ensureNotBanned(
      container,
      router: router,
    );
    return !allowed;
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

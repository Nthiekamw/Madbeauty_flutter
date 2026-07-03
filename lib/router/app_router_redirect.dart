import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_config.dart';
import '../features/auth/guest/guest_mode_provider.dart';
import '../features/auth/navigation/post_auth_navigation.dart';
import '../features/auth/providers/auth_redirect_providers.dart';
import '../services/auth/biometric_auth_providers.dart';
import '../services/auth/biometric_auth_service.dart';
import '../features/auth/guest/guest_route_policy.dart';
import '../features/auth/logic/auth_role_cache.dart';
import '../features/auth/providers/auth_notifier.dart';
import '../features/auth/providers/my_roles_provider.dart';
import '../features/auth/providers/password_recovery_provider.dart'
    show isPasswordRecoveryActiveProvider;
import '../features/auth/register/storage/register_wizard_draft_store.dart';
import '../services/storage/local_cache_service.dart';
import 'admin_route_policy.dart';
import 'app_deep_links.dart';
import 'app_routes.dart';
import 'prestataire_public_route.dart';

/// Logique de redirection globale GoRouter (auth, rôles, legacy).
String? appRouterRedirect(Ref ref, GoRouterState state) {
  if (PostAuthNavigation.isInFlight) return null;

  final auth = ref.read(authNotifierProvider);
  final recoveryActive = ref.read(isPasswordRecoveryActiveProvider);
  final guestMode = ref.read(guestModeProvider);

  final user = switch (auth) {
    AsyncData(:final value) => value,
    _ => null,
  };
  final hasSession = AppConfig.hasSupabase &&
      ref.read(authServiceProvider).currentSession != null;
  final isAuthenticated = hasSession && user != null;

  final location = state.matchedLocation;
  final registerDraft = RegisterWizardDraftStore.instance.read();
  final registerWizardOngoing = registerDraft != null && registerDraft.isActive;
  final publicRoutes = <String>{
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.welcome,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.registerVerifyEmail,
    AppRoutes.forgotPassword,
    AppRoutes.resetPassword,
    AppRoutes.bannedAccountSupport,
    if (kDebugMode) AppRoutes.asyncStateTest,
  };
  final guestOnlyRoutes = <String>{
    AppRoutes.welcome,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.registerVerifyEmail,
    AppRoutes.forgotPassword,
  };

  final preferredPath = AuthRoleCache.preferredAuthenticatedPath();
  final effectiveRole = AuthRoleCache.preferredAuthenticatedRole();
  final cachedServerRoles = LocalCacheService.instance.cachedServerRoles;
  final hasCachedAdminRole = AuthRoleCache.hasAdminAmong(cachedServerRoles);
  final hasAdminRole = hasCachedAdminRole ||
      ref.read(myRolesProvider).maybeWhen(
            data: (roles) => roles.any((r) => r.value == 'admin'),
            orElse: () => false,
          );

  String? legacyRedirect() {
    return switch (location) {
      AppRoutes.home => preferredPath,
      AppRoutes.listing => AppRoutes.clientSearch,
      AppRoutes.myReservations => AppRoutes.clientReservations,
      AppRoutes.prestataire when effectiveRole == 'prestataire' =>
        AppRoutes.prestataireProfile,
      AppRoutes.prestataire => AppRoutes.clientHome,
      _ => null,
    };
  }

  final legacy = legacyRedirect();
  if (legacy != null) return legacy;

  final sharedProfile = AppDeepLinks.legacyListingRedirect(location);
  if (sharedProfile != null) return sharedProfile;

  if (registerWizardOngoing) {
    if (location == AppRoutes.register ||
        location == AppRoutes.registerVerifyEmail) {
      return null;
    }
    if (registerDraft.pendingEmailVerification && !isAuthenticated) {
      return '${AppRoutes.registerVerifyEmail}?email=${Uri.encodeComponent(registerDraft.email.trim())}';
    }
    if (isAuthenticated) {
      if (location == AppRoutes.register) return null;
      if (registerDraft.step == 2) {
        return '${AppRoutes.register}?resume=1';
      }
      return AppRoutes.register;
    }
    return AppRoutes.register;
  }

  if (recoveryActive) {
    if (location != AppRoutes.resetPassword) {
      return AppRoutes.resetPassword;
    }
    return null;
  }

  if (auth.isLoading) {
    if (location == AppRoutes.register ||
        location == AppRoutes.registerVerifyEmail ||
        location == AppRoutes.login ||
        location == AppRoutes.forgotPassword ||
        location == AppRoutes.resetPassword) {
      return null;
    }
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  if (location == AppRoutes.resetPassword) {
    if (user == null) return AppRoutes.login;
    return null;
  }

  if (!isAuthenticated) {
    if (guestMode) {
      if (GuestRoutePolicy.requiresAccount(location)) {
        return location == AppRoutes.bookingConfirmation
            ? AppRoutes.login
            : AppRoutes.clientHome;
      }
      if (GuestRoutePolicy.isBrowsableAsGuest(location)) return null;
    }
    if (publicRoutes.contains(location)) return null;
    return AppRoutes.welcome;
  }

  if (LocalCacheService.instance.profileBiometricUnlockEnabled &&
      BiometricAuthService.isPlatformSupported &&
      !ref.read(biometricUnlockSessionProvider)) {
    if (location != AppRoutes.splash) return AppRoutes.splash;
    return null;
  }

  final handoffTarget = ref.read(splashRedirectTargetProvider);
  if (handoffTarget != null) {
    scheduleMicrotask(
      () => ref.read(splashRedirectTargetProvider.notifier).clear(),
    );
    return handoffTarget;
  }

  if (location == AppRoutes.splash) {
    return null;
  }

  if (location == AppRoutes.login) {
    if (isAuthenticated && ref.read(loginRedirectAfterWelcomeProvider)) {
      scheduleMicrotask(
        () => ref.read(loginRedirectAfterWelcomeProvider.notifier).disarm(),
      );
      return preferredPath;
    }
    return null;
  }

  if (location == AppRoutes.register ||
      location == AppRoutes.registerVerifyEmail) {
    return null;
  }

  if (hasAdminRole) {
    if (location == AppRoutes.role) {
      return AppRoutes.adminHome;
    }
    if (AdminRoutePolicy.shouldRedirectAdminAway(location)) {
      return AppRoutes.adminHome;
    }
    if (!AdminRoutePolicy.isAdminShellPath(location) &&
        !isPublicPrestataireProfilePath(location) &&
        !AdminRoutePolicy.isBugReportPath(location)) {
      return AppRoutes.adminHome;
    }
    return null;
  }

  if (location == AppRoutes.role) {
    return null;
  }

  if (location == AppRoutes.onboarding ||
      location == AppRoutes.welcome ||
      guestOnlyRoutes.contains(location)) {
    return preferredPath;
  }

  if (AdminRoutePolicy.isAdminShellPath(location)) {
    return preferredPath;
  }

  return null;
}

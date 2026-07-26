import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/user_role.dart';
import '../../../router/app_routes.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/auth/role_service.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../auth/logic/auth_role_cache.dart';
import '../../auth/providers/my_roles_provider.dart';
import '../../profile/logic/prestataire_hub_onboarding_draft.dart';
import '../logic/prestataire_profile_completeness.dart';
import '../providers/agenda/disponibilite_provider.dart';
import '../providers/profile/prestataire_profile_form_provider.dart';
import 'prestataire_hub_wizard_navigation.dart';

/// Navigation intelligente vers l'espace prestataire (devenir / hub / dashboard).
abstract final class PrestataireNavigation {
  PrestataireNavigation._();

  static Future<void> openSpace(BuildContext context, WidgetRef ref) async {
    final roles = await ref.read(myRolesProvider.future);
    if (!context.mounted) return;

    if (!roles.contains(UserRole.prestataire)) {
      context.goBecomePrestataire();
      return;
    }

    await AuthRoleCache.persistServerRoles(roles);
    await LocalCacheService.instance.setSelectedRole('prestataire');
    await LocalCacheService.instance.setSignupShellRole('prestataire');
    if (!context.mounted) return;
    await _goDashboardOrCompleteProfile(context, ref);
  }

  /// Après inscription prestataire : hub profil (choix déjà fait à l'étape 2).
  ///
  /// [container] : le widget d'inscription peut être démonté avant cette suite ;
  /// ne pas utiliser le [WidgetRef] du formulaire après des `await`.
  static Future<void> afterPrestaRegistration(
    BuildContext context,
    ProviderContainer container,
  ) async {
    await LocalCacheService.instance.setSelectedRole('prestataire');
    await LocalCacheService.instance.setSignupShellRole('prestataire');
    try {
      final rolesService = RoleService.fromEnv();
      final roles = await rolesService.getMyRoles();
      await AuthRoleCache.persistServerRoles(roles);
      container.invalidate(myRolesProvider);
    } catch (_) {
      // On continue avec le rôle local pour ne pas bloquer le parcours.
    }
    container.invalidate(prestataireProfileFormProvider);
    if (!context.mounted) return;
    await PrestataireHubWizardNavigation.openWizard(context, initialStep: 0);
  }

  /// Après [BecomePrestataireScreen] : hub pour photo, spécialités, services.
  static Future<void> afterBecomePrestataire(
    BuildContext context,
    WidgetRef ref,
  ) async {
    ref.invalidate(prestataireProfileFormProvider);
    if (!context.mounted) return;
    await PrestataireHubWizardNavigation.openWizard(context, initialStep: 0);
  }

  /// Bascule client â†’ prestataire : hub si profil incomplet, sinon dashboard.
  static Future<void> switchToPrestataireSpace(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await LocalCacheService.instance.setSelectedRole('prestataire');
    await LocalCacheService.instance.setSignupShellRole('prestataire');
    if (!context.mounted) return;
    await _goDashboardOrCompleteProfile(context, ref);
  }

  static Future<void> switchToPrestataireSpaceWithContainer(
    BuildContext context,
    ProviderContainer container,
  ) async {
    await LocalCacheService.instance.setSelectedRole('prestataire');
    await LocalCacheService.instance.setSignupShellRole('prestataire');
    if (!context.mounted) return;
    await _goDashboardOrCompleteProfileWithContainer(context, container);
  }

  static Future<void> switchToPrestataireSpaceWithRouter(
    GoRouter router,
    ProviderContainer container,
  ) async {
    await LocalCacheService.instance.setSelectedRole('prestataire');
    await LocalCacheService.instance.setSignupShellRole('prestataire');
    await _goDashboardOrCompleteProfileWithRouter(router, container);
  }

  /// Destination prestataire pour handoff redirect (sans navigation).
  static Future<String> prestataireSpacePath(ProviderContainer container) async {
    await LocalCacheService.instance.setSelectedRole('prestataire');
    await LocalCacheService.instance.setSignupShellRole('prestataire');
    try {
      final data = await container.read(prestataireProfileFormProvider.future);
      // Dashboard dès que le salon est opérationnel ; le wizard n’est forcé
      // que s’il manque l’essentiel (identité / adresse / services).
      if (data.isOperationalForDashboard) {
        if (data.isProfessionallyComplete) {
          unawaited(PrestataireHubOnboardingDraft.clearAfterProfileComplete());
        }
        return AppRoutes.prestataireDashboard;
      }
      return AppRoutes.prestataireProfileEdit;
    } catch (_) {
      return AppRoutes.prestataireDashboard;
    }
  }

  static Future<void> _goDashboardOrCompleteProfile(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final data = await ref.read(prestataireProfileFormProvider.future);
      final hasHoraires = ref.read(prestataireHorairesProvider).maybeWhen(
            data: (h) => h.isNotEmpty,
            orElse: () => false,
          );
      if (!context.mounted) return;
      _goFromProfileData(context, data, hasHoraires: hasHoraires);
    } catch (_) {
      if (!context.mounted) return;
      context.goPrestataireDashboard();
    }
  }

  static Future<void> _goDashboardOrCompleteProfileWithContainer(
    BuildContext context,
    ProviderContainer container,
  ) async {
    try {
      final data = await container.read(prestataireProfileFormProvider.future);
      final hasHoraires = container.read(prestataireHorairesProvider).maybeWhen(
            data: (h) => h.isNotEmpty,
            orElse: () => false,
          );
      if (!context.mounted) return;
      _goFromProfileData(context, data, hasHoraires: hasHoraires);
    } catch (_) {
      if (!context.mounted) return;
      context.goPrestataireDashboard();
    }
  }

  static Future<void> _goDashboardOrCompleteProfileWithRouter(
    GoRouter router,
    ProviderContainer container,
  ) async {
    try {
      final data = await container.read(prestataireProfileFormProvider.future);
      final hasHoraires = container.read(prestataireHorairesProvider).maybeWhen(
            data: (h) => h.isNotEmpty,
            orElse: () => false,
          );
      await _goFromProfileDataWithRouter(
        router,
        data,
        hasHoraires: hasHoraires,
      );
    } catch (_) {
      await router.goNamedDeferred(AppRouteNames.prestataireDashboard);
    }
  }

  static void _goFromProfileData(
    BuildContext context,
    PrestataireProfileFormData data, {
    bool hasHoraires = false,
  }) {
    if (data.isOperationalForDashboard) {
      if (data.isProfessionallyComplete) {
        unawaited(PrestataireHubOnboardingDraft.clearAfterProfileComplete());
      }
      context.goPrestataireDashboard();
      return;
    }
    unawaited(
      PrestataireHubWizardNavigation.openWizard(
        context,
        initialStep: PrestataireHubWizardNavigation.hubStepFromProfileData(
          data,
          hasHoraires: hasHoraires,
        ),
      ),
    );
  }

  static Future<void> _goFromProfileDataWithRouter(
    GoRouter router,
    PrestataireProfileFormData data, {
    bool hasHoraires = false,
  }) async {
    if (data.isOperationalForDashboard) {
      if (data.isProfessionallyComplete) {
        unawaited(PrestataireHubOnboardingDraft.clearAfterProfileComplete());
      }
      await router.goNamedDeferred(AppRouteNames.prestataireDashboard);
      return;
    }
    await router.goNamedDeferred(AppRouteNames.prestataireDashboard);
    final context = router.routerDelegate.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    await PrestataireHubWizardNavigation.openWizard(
      context,
      initialStep: PrestataireHubWizardNavigation.hubStepFromProfileData(
        data,
        hasHoraires: hasHoraires,
      ),
    );
  }
}


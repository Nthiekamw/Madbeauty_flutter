import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_role.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../auth/logic/auth_role_cache.dart';
import '../../auth/providers/my_roles_provider.dart';
import '../../profile/logic/prestataire_hub_onboarding_draft.dart';
import '../logic/prestataire_profile_completeness.dart';
import '../providers/prestataire_profile_form_provider.dart';

/// Navigation intelligente vers l’espace prestataire (devenir / hub / dashboard).
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

  /// Après inscription prestataire : hub profil (choix déjà fait à l’étape 2).
  static Future<void> afterPrestaRegistration(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await LocalCacheService.instance.setSelectedRole('prestataire');
    await LocalCacheService.instance.setSignupShellRole('prestataire');
    try {
      ref.invalidate(myRolesProvider);
      final roles = await ref.read(myRolesProvider.future);
      await AuthRoleCache.persistServerRoles(roles);
    } catch (_) {
      // On continue avec le rôle local pour ne pas bloquer le parcours.
    }
    await PrestataireHubOnboardingDraft.markStep2Started();
    ref.invalidate(prestataireProfileFormProvider);
    if (!context.mounted) return;
    context.goPrestataireProfile();
    if (!context.mounted) return;
    context.pushPrestataireProfileEdit();
  }

  /// Après [BecomePrestataireScreen] : hub pour photo, spécialités, services.
  static Future<void> afterBecomePrestataire(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await PrestataireHubOnboardingDraft.markStep2Started();
    ref.invalidate(prestataireProfileFormProvider);
    if (!context.mounted) return;
    context.goPrestataireProfile();
    if (!context.mounted) return;
    context.pushPrestataireProfileEdit();
  }

  /// Bascule client → prestataire : hub si profil incomplet, sinon dashboard.
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

  static Future<void> _goDashboardOrCompleteProfile(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final data = await ref.read(prestataireProfileFormProvider.future);
      if (!context.mounted) return;
      _goFromProfileData(context, data);
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
      if (!context.mounted) return;
      _goFromProfileData(context, data);
    } catch (_) {
      if (!context.mounted) return;
      context.goPrestataireDashboard();
    }
  }

  static void _goFromProfileData(
    BuildContext context,
    PrestataireProfileFormData data,
  ) {
    if (data.isProfessionallyComplete) {
      unawaited(PrestataireHubOnboardingDraft.clearAfterProfileComplete());
      context.goPrestataireDashboard();
      return;
    }
    context.goPrestataireProfile();
    context.pushPrestataireProfileEdit();
  }
}

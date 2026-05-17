import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_role.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../auth/logic/auth_role_cache.dart';
import '../../auth/providers/my_roles_provider.dart';
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
    if (!context.mounted) return;
    await _goDashboardOrCompleteProfile(context, ref);
  }

  /// Après inscription prestataire : dashboard + message « complète ton profil ».
  static Future<void> afterPrestaRegistration(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await LocalCacheService.instance.setSelectedRole('prestataire');
    ref.invalidate(prestataireProfileFormProvider);
    if (!context.mounted) return;
    context.goPrestataireDashboard();
  }

  /// Après [BecomePrestataireScreen] : hub pour photo, spécialités, services.
  static Future<void> afterBecomePrestataire(
    BuildContext context,
    WidgetRef ref,
  ) async {
    ref.invalidate(prestataireProfileFormProvider);
    if (!context.mounted) return;
    context.goPrestataireProfile();
  }

  /// Bascule client → prestataire : hub si profil incomplet, sinon dashboard.
  static Future<void> switchToPrestataireSpace(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await LocalCacheService.instance.setSelectedRole('prestataire');
    if (!context.mounted) return;
    await _goDashboardOrCompleteProfile(context, ref);
  }

  static Future<void> switchToPrestataireSpaceWithContainer(
    BuildContext context,
    ProviderContainer container,
  ) async {
    await LocalCacheService.instance.setSelectedRole('prestataire');
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
      context.goPrestataireDashboard();
    } else {
      context.goPrestataireProfile();
    }
  }
}

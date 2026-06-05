import 'package:flutter/material.dart';

import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/prestataire/profile_form/prestataire_profile_form_service.dart';
import '../../profile/logic/prestataire_hub_onboarding_draft.dart';
import '../logic/prestataire_profile_completeness.dart';

/// Point d’entrée unique du parcours profil prestataire (7 étapes, hub).
abstract final class PrestataireHubWizardNavigation {
  PrestataireHubWizardNavigation._();

  static const hubStepCount = 7;

  /// Première étape hub à traiter selon l’état du profil.
  static int hubStepFromProfileData(
    PrestataireProfileFormData data, {
    required bool hasHoraires,
  }) {
    final missing = data.missingChecklistItems;
    if (missing.isNotEmpty) {
      return switch (missing.first) {
        PrestaCompletionChecklistItem.basics => 0,
        PrestaCompletionChecklistItem.services => 2,
        PrestaCompletionChecklistItem.gallery => 3,
      };
    }
    final enhancements = data.missingEnhancements(hasHoraires: hasHoraires);
    if (enhancements.isNotEmpty) {
      return switch (enhancements.first) {
        PrestaProfileEnhancementItem.clientExperience => 4,
        PrestaProfileEnhancementItem.gallery => 3,
        PrestaProfileEnhancementItem.horaires => 5,
      };
    }
    return 6;
  }

  /// Prépare le brouillon hub pour le parcours guidé.
  static Future<void> prepareWizardSession({int? step}) async {
    await PrestataireHubOnboardingDraft.markStep2Started();
    if (step != null) {
      await PrestataireHubOnboardingDraft.seedCurrentStep(step);
    }
  }

  /// Ouvre le hub profil en mode assistant (7 étapes).
  static Future<void> openWizard(
    BuildContext context, {
    int? initialStep,
  }) async {
    await prepareWizardSession(step: initialStep);
    if (!context.mounted) return;
    context.goPrestataireProfile();
    if (!context.mounted) return;
    if (initialStep != null) {
      context.pushPrestataireProfileEditAtStep(initialStep);
    } else {
      context.pushPrestataireProfileEdit();
    }
  }
}

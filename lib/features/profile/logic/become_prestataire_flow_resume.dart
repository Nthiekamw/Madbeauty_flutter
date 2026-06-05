import '../../../router/app_router.dart';
import '../../../services/storage/local_cache_service.dart';
import '../storage/become_prestataire_draft_store.dart';
import 'prestataire_hub_onboarding_draft.dart';

/// Chemins de reprise du parcours « devenir prestataire » / complétion hub.
abstract final class BecomePrestataireFlowResume {
  BecomePrestataireFlowResume._();

  static String? pathIfPending() {
    final draft = BecomePrestataireDraftStore.instance.read();
    if (draft == null || !draft.isActive) return null;
    if (draft.step1Submitted && draft.step2Started) {
      return AppRoutes.prestataireProfileEdit;
    }
    return AppRoutes.becomePrestataire;
  }

  static bool get hasPending => pathIfPending() != null;

  static bool get needsPrestataireRole {
    final draft = BecomePrestataireDraftStore.instance.read();
    return draft != null && draft.isActive && draft.step1Submitted;
  }

  /// Reprise après redémarrage : brouillon local ou profil prestataire incomplet.
  static String? pathAfterAuthBootstrap() {
    final draftPath = pathIfPending();
    if (draftPath != null) return draftPath;

    if (LocalCacheService.instance.selectedRole == 'prestataire' &&
        PrestataireHubOnboardingDraft.hasPendingCompletion) {
      return AppRoutes.prestataireProfileEdit;
    }
    return null;
  }
}


import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/prestataire/prestataire_subscription_status.dart';
import '../../../core/models/domain/user/prestataire_profile.dart';
import '../../../services/supabase/prestataire/profile_form/prestataire_profile_form_service.dart';
import 'prestataire_profile_completeness.dart';

/// Raison d’un rappel visibilité prestataire (catalogue / carte).
enum PrestataireVisibilityNudgeKind {
  incompleteProfile,
  missingMapLocation,
  needsSubscription,
}

class PrestataireVisibilityNudge {
  const PrestataireVisibilityNudge({
    required this.kind,
    required this.inAppId,
    required this.pushType,
    required this.title,
    required this.body,
  });

  final PrestataireVisibilityNudgeKind kind;
  final String inAppId;
  final String pushType;
  final String title;
  final String body;
}

/// Détermine si un rappel push / in-app est nécessaire pour le prestataire.
PrestataireVisibilityNudge? resolvePrestataireVisibilityNudge({
  required PrestataireProfileFormData? form,
  required PrestataireProfile? storedProfile,
  required PrestataireSubscriptionStatus? subscription,
}) {
  if (form == null || subscription == null) return null;

  if (!form.isProfessionallyComplete) {
    final addressMissing = !form.hasSalonAddress || !form.hasPostalCode;
    return PrestataireVisibilityNudge(
      kind: PrestataireVisibilityNudgeKind.incompleteProfile,
      inAppId: 'prestataire_visibility_incomplete_profile',
      pushType: 'prestataire_profile_incomplete',
      title: DiscPrestaWorkspace.visibilityIncompleteTitle,
      body: addressMissing
          ? DiscPrestaWorkspace.visibilityMissingMapBody
          : DiscPrestaWorkspace.visibilityIncompleteBody,
    );
  }

  if (!subscription.hasCatalogAccess) {
    return PrestataireVisibilityNudge(
      kind: PrestataireVisibilityNudgeKind.needsSubscription,
      inAppId: 'prestataire_catalog_visibility_nudge',
      pushType: 'prestataire_catalog_visibility',
      title: DiscPrestaSub.notVisibleReminderTitle,
      body: DiscPrestaSub.notVisibleReminderBody,
    );
  }

  final lat = storedProfile?.latitude;
  final lng = storedProfile?.longitude;
  if (lat == null || lng == null) {
    return PrestataireVisibilityNudge(
      kind: PrestataireVisibilityNudgeKind.missingMapLocation,
      inAppId: 'prestataire_visibility_missing_map',
      pushType: 'prestataire_map_missing',
      title: DiscPrestaWorkspace.visibilityMissingMapTitle,
      body: DiscPrestaWorkspace.visibilityMissingMapBody,
    );
  }

  return null;
}

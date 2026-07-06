import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/models/domain/prestataire/prestataire_subscription_status.dart';
import '../../../../services/supabase/prestataire/subscription/prestataire_subscription_providers.dart';
import '../../logic/prestataire_profile_completeness.dart';
import '../profile/prestataire_profile_form_provider.dart';

/// Abonnement Stripe actif ou essai catalogue (accès catalogue + actions pro).
final prestataireHasActiveSubscriptionProvider = Provider<bool>((ref) {
  final status = ref.watch(
    prestataireSubscriptionStatusProvider.select((a) => a.value),
  );
  return status?.hasCatalogAccess ?? false;
});

/// Essai catalogue en cours (sans abonnement payant).
final prestataireIsInCatalogTrialProvider = Provider<bool>((ref) {
  final status = ref.watch(
    prestataireSubscriptionStatusProvider.select((a) => a.value),
  );
  return status?.isInCatalogTrial ?? false;
});

/// Jours restants d’essai catalogue (null si pas en essai).
final prestataireCatalogTrialDaysRemainingProvider = Provider<int?>((ref) {
  final status = ref.watch(
    prestataireSubscriptionStatusProvider.select((a) => a.value),
  );
  return status?.catalogTrialDaysRemaining;
});

/// Profil prêt catalogue mais sans accès (ni abo ni essai).
final prestataireNeedsSubscriptionForCatalogProvider = Provider<bool>((ref) {
  final profile = ref.watch(
    prestataireProfileFormProvider.select((a) => a.value),
  );
  final status = ref.watch(
    prestataireSubscriptionStatusProvider.select((a) => a.value),
  );
  if (profile == null || status == null) return false;
  return profile.isProfessionallyComplete && !status.hasCatalogAccess;
});

/// Visible dans le catalogue client (profil complet + abo ou essai).
final prestataireIsCatalogVisibleProvider = Provider<bool>((ref) {
  final profile = ref.watch(
    prestataireProfileFormProvider.select((a) => a.value),
  );
  final hasAccess = ref.watch(prestataireHasActiveSubscriptionProvider);
  if (profile == null) return false;
  return profile.isProfessionallyComplete && hasAccess;
});

/// Peut confirmer / refuser des réservations.
final prestataireCanManageBookingsProvider = Provider<bool>((ref) {
  return ref.watch(prestataireHasActiveSubscriptionProvider);
});

/// Attend le statut catalogue si besoin (évite un faux « visibilité requise » au 1er clic).
Future<bool> resolvePrestataireCanManageBookings(WidgetRef ref) async {
  if (!AppConfig.hasSupabase) return false;
  final status = await ref.read(prestataireSubscriptionStatusProvider.future);
  return status.hasCatalogAccess;
}

PrestataireSubscriptionStatus prestataireSubscriptionStatusOrEmpty(
  AsyncValue<PrestataireSubscriptionStatus> async,
) {
  return async.value ?? PrestataireSubscriptionStatus.empty();
}

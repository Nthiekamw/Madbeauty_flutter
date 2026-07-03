import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/notifications/prestataire_catalog_visibility_reminders.dart';
import '../../../services/supabase/prestataire/subscription/prestataire_subscription_providers.dart';
import '../providers/subscription/prestataire_subscription_gate_provider.dart';
import '../providers/subscription/prestataire_subscription_provider.dart';

/// Recharge le statut d’abonnement catalogue depuis Supabase.
Future<void> refreshPrestataireSubscription(WidgetRef ref) async {
  ref.invalidate(prestataireSubscriptionStatusProvider);
  ref.invalidate(prestatairePublishedServiceCountProvider);

  if (ref.read(prestataireHasActiveSubscriptionProvider)) {
    await PrestataireCatalogVisibilityReminders.instance.cancelAll();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/notifications/prestataire_catalog_visibility_reminders.dart';
import '../../../services/stripe/stripe_subscription_providers.dart';
import '../providers/subscription/prestataire_subscription_gate_provider.dart';
import '../providers/subscription/prestataire_subscription_provider.dart';

/// Synchronise l’abonnement Stripe puis invalide les providers locaux.
Future<void> refreshPrestataireSubscription(WidgetRef ref) async {
  final service = ref.read(stripePrestaSubscriptionServiceProvider);
  if (service != null) {
    try {
      await service.syncFromStripe();
    } catch (_) {}
  }
  ref.invalidate(prestataireSubscriptionStatusProvider);
  ref.invalidate(prestatairePublishedServiceCountProvider);

  if (ref.read(prestataireHasActiveSubscriptionProvider)) {
    await PrestataireCatalogVisibilityReminders.instance.cancelAll();
  }
}

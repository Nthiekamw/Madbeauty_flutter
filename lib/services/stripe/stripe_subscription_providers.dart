import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../features/prestataire/models/prestataire_subscription_status.dart';
import '../supabase/supabase_service.dart';
import 'stripe_prestataire_subscription_service.dart';
import 'stripe_service.dart';

final stripePrestaSubscriptionServiceProvider =
    Provider<StripePrestaSubscriptionService?>((ref) {
  if (!AppConfig.hasSupabase || !StripeService.isConfigured) return null;
  return StripePrestaSubscriptionService(SupabaseService.client);
});

final prestataireSubscriptionStatusProvider =
    FutureProvider.autoDispose<PrestataireSubscriptionStatus>((ref) async {
  final service = ref.watch(stripePrestaSubscriptionServiceProvider);
  if (service == null) return PrestataireSubscriptionStatus.empty();
  return service.fetchStatus();
});

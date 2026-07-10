import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/config/stripe_platform_policy.dart';
import '../supabase/supabase_service.dart';
import 'stripe_prestataire_subscription_service.dart';

final stripePrestaSubscriptionServiceProvider =
    Provider<StripePrestaSubscriptionService?>((ref) {
  if (!AppConfig.hasSupabase || !StripePlatformPolicy.isEnabled) return null;
  return StripePrestaSubscriptionService(SupabaseService.client);
});

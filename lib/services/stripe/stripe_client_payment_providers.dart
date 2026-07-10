import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/config/stripe_platform_policy.dart';
import '../supabase/supabase_service.dart';
import 'stripe_client_payment_service.dart';

final stripeClientPaymentServiceProvider =
    Provider<StripeClientPaymentService?>((ref) {
  if (!AppConfig.hasSupabase || !StripePlatformPolicy.isEnabled) return null;
  return StripeClientPaymentService(SupabaseService.client);
});

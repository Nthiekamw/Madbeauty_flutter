import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../supabase/supabase_service.dart';
import 'stripe_client_payment_service.dart';

final stripeClientPaymentServiceProvider =
    Provider<StripeClientPaymentService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return StripeClientPaymentService(SupabaseService.client);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../supabase/supabase_service.dart';
import 'stripe_booking_payment_service.dart';

final stripeBookingPaymentServiceProvider =
    Provider<StripeBookingPaymentService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return StripeBookingPaymentService(SupabaseService.client);
});

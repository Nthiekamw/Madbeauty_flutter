import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/config/stripe_platform_policy.dart';
import '../supabase/supabase_service.dart';
import 'stripe_connect_service.dart';

final stripeConnectServiceProvider = Provider<StripeConnectService?>((ref) {
  if (!AppConfig.hasSupabase || !StripePlatformPolicy.isEnabled) return null;
  return StripeConnectService(SupabaseService.client);
});

final prestataireStripeConnectProvider =
    FutureProvider.autoDispose<StripeConnectStatus?>((ref) async {
  final service = ref.watch(stripeConnectServiceProvider);
  if (service == null) return null;
  return service.syncStatus();
});


import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/models/domain/prestataire/prestataire_subscription_status.dart';
import '../../supabase_service.dart';

final prestataireSubscriptionStatusProvider =
    FutureProvider.autoDispose<PrestataireSubscriptionStatus>((ref) async {
  if (!AppConfig.hasSupabase) return PrestataireSubscriptionStatus.empty();

  final userId = SupabaseService.client.auth.currentUser?.id;
  if (userId == null) return PrestataireSubscriptionStatus.empty();

  final row = await SupabaseService.client
      .from('prestataire_profiles')
      .select(
        'subscription_status, subscription_tier, subscription_interval, '
        'subscription_current_period_end, stripe_subscription_id, '
        'catalog_trial_ends_at',
      )
      .eq('user_id', userId)
      .maybeSingle();

  if (row == null) return PrestataireSubscriptionStatus.empty();
  return PrestataireSubscriptionStatus.fromRow(
    Map<String, dynamic>.from(row),
  );
});

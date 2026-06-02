import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../supabase_service.dart';
import 'referral_service.dart';

final referralServiceProvider = Provider<ReferralService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return ReferralService(SupabaseService.client);
});

final myReferralInfoProvider = FutureProvider.autoDispose<ReferralInfo?>((ref) async {
  final service = ref.watch(referralServiceProvider);
  if (service == null) return null;
  return service.getMyReferralInfo();
});

/// Pourcentage de remise parrainage active (prochaine résa), ou null.
final clientReferralDiscountPercentProvider = Provider<int?>((ref) {
  return ref.watch(myReferralInfoProvider).maybeWhen(
        data: (info) => info?.activeDiscountPercent,
        orElse: () => null,
      );
});

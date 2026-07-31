import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../supabase_service.dart';
import 'loyalty_service.dart';

final loyaltyServiceProvider = Provider<LoyaltyService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return LoyaltyService(SupabaseService.client);
});

final myLoyaltyInfoProvider =
    FutureProvider.autoDispose<LoyaltyInfo?>((ref) async {
  final service = ref.watch(loyaltyServiceProvider);
  if (service == null) return null;
  return service.getMyLoyaltyInfo();
});

/// True si le client peut appliquer la récompense sur la prochaine résa.
final clientLoyaltyCanRedeemProvider = Provider<bool>((ref) {
  return ref.watch(myLoyaltyInfoProvider).maybeWhen(
        data: (info) => info?.canRedeem == true,
        orElse: () => false,
      );
});

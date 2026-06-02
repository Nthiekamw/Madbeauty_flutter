import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../../services/supabase/referral/referral_providers.dart';
import '../../../services/supabase/referral/referral_service.dart';

/// Applique un code parrain stocké après ouverture d’un lien d’invitation.
Future<ApplyReferralResult?> applyPendingReferralCode(WidgetRef ref) async {
  final pending = LocalCacheService.instance.pendingReferralCode?.trim();
  if (pending == null || pending.isEmpty) return null;

  final service = ref.read(referralServiceProvider);
  if (service == null) return null;

  final result = await service.applyReferralCode(pending);
  if (result == ApplyReferralResult.success ||
      result == ApplyReferralResult.alreadyReferred) {
    await LocalCacheService.instance.clearPendingReferralCode();
  }
  ref.invalidate(myReferralInfoProvider);
  return result;
}

String messageForApplyResult(ApplyReferralResult result) {
  switch (result) {
    case ApplyReferralResult.success:
      return DiscReferral.referredWelcome;
    case ApplyReferralResult.invalidCode:
    case ApplyReferralResult.codeNotFound:
      return DiscReferral.applyErrInvalid;
    case ApplyReferralResult.selfReferral:
      return DiscReferral.applyErrSelf;
    case ApplyReferralResult.alreadyReferred:
      return DiscReferral.applyErrUsed;
    case ApplyReferralResult.clientNotFound:
    case ApplyReferralResult.unknown:
      return DiscReferral.loadErr;
  }
}

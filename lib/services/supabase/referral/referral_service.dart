import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';

class ReferralBookingDiscount {
  const ReferralBookingDiscount({
    required this.available,
    required this.percent,
    this.reason,
    required this.label,
  });

  final bool available;
  final int percent;
  final String? reason;
  final String label;
}

class ReferralInfo {
  const ReferralInfo({
    required this.code,
    required this.invitationsCount,
    required this.hasReferrer,
    required this.isAmbassador,
    required this.tier,
    this.nextMilestone,
    required this.rewardMessage,
    this.discount,
  });

  final String code;
  final int invitationsCount;
  final bool hasReferrer;
  final bool isAmbassador;
  /// `none` | `friend` | `ambassador`
  final String tier;
  final int? nextMilestone;
  final String rewardMessage;
  final ReferralBookingDiscount? discount;

  int? get activeDiscountPercent =>
      discount?.available == true && (discount?.percent ?? 0) > 0
          ? discount!.percent
          : null;
}

enum ApplyReferralResult {
  success,
  invalidCode,
  codeNotFound,
  selfReferral,
  alreadyReferred,
  clientNotFound,
  unknown,
}

class ReferralService {
  ReferralService(this._client);

  final SupabaseClient _client;

  Future<ReferralInfo?> getMyReferralInfo() => SupabaseErrorHandler.run(
        operation: 'referral.getMyReferralInfo',
        action: () async {
          final raw = await _client.rpc('get_my_referral_info');
          if (raw is! Map) return null;
          final map = Map<String, dynamic>.from(raw);
          if (map['error'] != null) return null;
          final code = map['code'] as String?;
          if (code == null || code.trim().isEmpty) return null;
          ReferralBookingDiscount? discount;
          final discountRaw = map['discount'];
          if (discountRaw is Map) {
            final d = Map<String, dynamic>.from(discountRaw);
            discount = ReferralBookingDiscount(
              available: d['available'] == true,
              percent: (d['percent'] as num?)?.toInt() ?? 0,
              reason: d['reason'] as String?,
              label: d['label'] as String? ?? '',
            );
          }

          return ReferralInfo(
            code: code.trim().toUpperCase(),
            invitationsCount: (map['invitations_count'] as num?)?.toInt() ?? 0,
            hasReferrer: map['has_referrer'] == true,
            isAmbassador: map['is_ambassador'] == true,
            tier: map['tier'] as String? ?? 'none',
            nextMilestone: (map['next_milestone'] as num?)?.toInt(),
            rewardMessage: map['reward_message'] as String? ?? '',
            discount: discount,
          );
        },
      );

  Future<ApplyReferralResult> applyReferralCode(String code) =>
      SupabaseErrorHandler.run(
        operation: 'referral.applyReferralCode',
        action: () async {
          final raw = await _client.rpc(
            'apply_referral_code',
            params: {'p_code': code.trim().toUpperCase()},
          );
          if (raw is! Map) return ApplyReferralResult.unknown;
          final map = Map<String, dynamic>.from(raw);
          if (map['ok'] == true) return ApplyReferralResult.success;
          return _mapError(map['error'] as String?);
        },
      );

  ApplyReferralResult _mapError(String? error) {
    switch (error) {
      case 'invalid_code':
        return ApplyReferralResult.invalidCode;
      case 'code_not_found':
        return ApplyReferralResult.codeNotFound;
      case 'self_referral':
        return ApplyReferralResult.selfReferral;
      case 'already_referred':
        return ApplyReferralResult.alreadyReferred;
      case 'client_not_found':
        return ApplyReferralResult.clientNotFound;
      default:
        return ApplyReferralResult.unknown;
    }
  }
}


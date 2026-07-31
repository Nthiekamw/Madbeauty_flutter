import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/loyalty_config.dart';
import '../../../core/errors/supabase_error_handler.dart';

class LoyaltyBadge {
  const LoyaltyBadge({
    required this.id,
    required this.threshold,
    required this.unlocked,
  });

  final String id;
  final int threshold;
  final bool unlocked;
}

class LoyaltyInfo {
  const LoyaltyInfo({
    required this.points,
    required this.pointsEarnedTotal,
    required this.rewardsRedeemed,
    required this.pointsPerBooking,
    required this.pointsPerReward,
    required this.maxRewardCents,
    required this.progressPoints,
    required this.pointsRemaining,
    required this.canRedeem,
    required this.badges,
  });

  final int points;
  final int pointsEarnedTotal;
  final int rewardsRedeemed;
  final int pointsPerBooking;
  final int pointsPerReward;
  final int maxRewardCents;
  final int progressPoints;
  final int pointsRemaining;
  final bool canRedeem;
  final List<LoyaltyBadge> badges;

  double get progressFraction {
    if (pointsPerReward <= 0) return 0;
    return (progressPoints / pointsPerReward).clamp(0.0, 1.0);
  }

  int get maxRewardEuros => (maxRewardCents / 100).round();
}

class LoyaltyService {
  LoyaltyService(this._client);

  final SupabaseClient _client;

  Future<LoyaltyInfo?> getMyLoyaltyInfo() => SupabaseErrorHandler.run(
        operation: 'loyalty.getMyLoyaltyInfo',
        action: () async {
          final raw = await _client.rpc('get_my_loyalty_info');
          if (raw is! Map) return null;
          final map = Map<String, dynamic>.from(raw);
          if (map['error'] != null) return null;

          final badgesRaw = map['badges'];
          final badges = <LoyaltyBadge>[];
          if (badgesRaw is List) {
            for (final item in badgesRaw) {
              if (item is! Map) continue;
              final b = Map<String, dynamic>.from(item);
              badges.add(
                LoyaltyBadge(
                  id: b['id'] as String? ?? '',
                  threshold: (b['threshold'] as num?)?.toInt() ?? 0,
                  unlocked: b['unlocked'] == true,
                ),
              );
            }
          }

          return LoyaltyInfo(
            points: (map['points'] as num?)?.toInt() ?? 0,
            pointsEarnedTotal:
                (map['points_earned_total'] as num?)?.toInt() ?? 0,
            rewardsRedeemed: (map['rewards_redeemed'] as num?)?.toInt() ?? 0,
            pointsPerBooking: (map['points_per_booking'] as num?)?.toInt() ??
                LoyaltyConfig.pointsPerEligibleBooking,
            pointsPerReward: (map['points_per_reward'] as num?)?.toInt() ??
                LoyaltyConfig.pointsPerReward,
            maxRewardCents: (map['max_reward_cents'] as num?)?.toInt() ??
                LoyaltyConfig.maxRewardCents,
            progressPoints: (map['progress_points'] as num?)?.toInt() ?? 0,
            pointsRemaining: (map['points_remaining'] as num?)?.toInt() ??
                LoyaltyConfig.pointsPerReward,
            canRedeem: map['can_redeem'] == true,
            badges: badges,
          );
        },
      );
}

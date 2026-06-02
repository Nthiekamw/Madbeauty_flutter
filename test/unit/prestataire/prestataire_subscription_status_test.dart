import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/features/prestataire/models/prestataire_subscription_status.dart';

void main() {
  test('isActive pour active et trialing', () {
    expect(
      const PrestataireSubscriptionStatus(status: 'active').isActive,
      isTrue,
    );
    expect(
      const PrestataireSubscriptionStatus(status: 'trialing').isActive,
      isTrue,
    );
    expect(
      const PrestataireSubscriptionStatus(status: 'none').isActive,
      isFalse,
    );
  });

  test('fromRow parse la date de fin de période', () {
    final status = PrestataireSubscriptionStatus.fromRow({
      'subscription_status': 'active',
      'subscription_tier': 'solo',
      'subscription_interval': 'month',
      'subscription_current_period_end': '2026-07-01T12:00:00.000Z',
      'stripe_subscription_id': 'sub_123',
    });
    expect(status.tier, 'solo');
    expect(status.periodEnd, isNotNull);
  });
}

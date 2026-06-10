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

  test('hasCatalogAccess inclut essai catalogue', () {
    final future = DateTime.now().toUtc().add(const Duration(days: 3));
    final status = PrestataireSubscriptionStatus(
      status: 'none',
      catalogTrialEndsAt: future,
    );
    expect(status.isInCatalogTrial, isTrue);
    expect(status.hasCatalogAccess, isTrue);
    expect(status.isActive, isFalse);
  });

  test('essai catalogue expiré', () {
    final past = DateTime.now().toUtc().subtract(const Duration(days: 1));
    final status = PrestataireSubscriptionStatus(
      status: 'none',
      catalogTrialEndsAt: past,
    );
    expect(status.isInCatalogTrial, isFalse);
    expect(status.hasCatalogAccess, isFalse);
  });

  test('fromRow parse la date de fin de période et essai', () {
    final status = PrestataireSubscriptionStatus.fromRow({
      'subscription_status': 'active',
      'subscription_tier': 'solo',
      'subscription_interval': 'month',
      'subscription_current_period_end': '2026-07-01T12:00:00.000Z',
      'stripe_subscription_id': 'sub_123',
      'catalog_trial_ends_at': '2026-06-20T12:00:00.000Z',
    });
    expect(status.tier, 'solo');
    expect(status.periodEnd, isNotNull);
    expect(status.catalogTrialEndsAt, isNotNull);
  });
}

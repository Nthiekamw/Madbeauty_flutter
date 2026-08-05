import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/config/prestataire_subscription_config.dart';

void main() {
  test('tierForServiceCount', () {
    expect(
      PrestataireSubscriptionConfig.tierForServiceCount(1).monthlyEur,
      18,
    );
    expect(
      PrestataireSubscriptionConfig.tierForServiceCount(1).yearlyEur,
      180,
    );
    expect(
      PrestataireSubscriptionConfig.tierForServiceCount(2).monthlyEur,
      24.99,
    );
    expect(
      PrestataireSubscriptionConfig.tierForServiceCount(5).yearlyEur,
      250,
    );
  });
}

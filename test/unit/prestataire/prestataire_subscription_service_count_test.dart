import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/config/prestataire_subscription_config.dart';
import 'package:madbeauty/features/prestataire/logic/prestataire_subscription_service_count.dart';

void main() {
  test('resolve prend le max publié / prévu', () {
    expect(
      PrestataireSubscriptionServiceCount.resolve(
        publishedCount: 1,
        plannedCount: 3,
      ),
      3,
    );
    expect(
      PrestataireSubscriptionConfig.tierForServiceCount(3).id,
      'multi',
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/config/market_config.dart';
import 'package:madbeauty/core/logic/market/prestataire_market_filter.dart';
import 'package:madbeauty/core/models/domain/user/prestataire_profile.dart';

PrestataireProfile _profile({String? pays}) {
  return PrestataireProfile(
    id: 'p1',
    userId: 'u1',
    pays: pays,
    createdAt: DateTime.utc(2024, 1, 1),
  );
}

void main() {
  group('prestataireProfileMatchesMarket', () {
    test('matches explicit country', () {
      expect(
        prestataireProfileMatchesMarket(_profile(pays: 'BE'), 'BE'),
        isTrue,
      );
      expect(
        prestataireProfileMatchesMarket(_profile(pays: 'BE'), 'FR'),
        isFalse,
      );
    });

    test('normalizes full country labels', () {
      expect(
        prestataireProfileMatchesMarket(_profile(pays: 'Belgique'), 'BE'),
        isTrue,
      );
      expect(
        prestataireProfileMatchesMarket(_profile(pays: 'France'), 'FR'),
        isTrue,
      );
      expect(
        prestataireProfileMatchesMarket(_profile(pays: 'Canada'), 'CA'),
        isTrue,
      );
    });
  });
}

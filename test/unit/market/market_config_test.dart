import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/config/market_config.dart';

void main() {
  group('MarketConfig', () {
    test('normalizeCountryCode maps labels and defaults unknown to FR', () {
      expect(MarketConfig.normalizeCountryCode('be'), 'BE');
      expect(MarketConfig.normalizeCountryCode('Canada'), 'CA');
      expect(MarketConfig.normalizeCountryCode('BELGIUM'), 'BE');
      expect(MarketConfig.normalizeCountryCode('XX'), 'FR');
      expect(MarketConfig.normalizeCountryCode(null), 'FR');
    });

    test('isSupported accepts only configured markets', () {
      expect(MarketConfig.isSupported('FR'), isTrue);
      expect(MarketConfig.isSupported('CA'), isTrue);
      expect(MarketConfig.isSupported('US'), isFalse);
    });

    test('definitionFor returns currency metadata', () {
      final ca = MarketConfig.definitionFor('CA');
      expect(ca.currencyCode, 'CAD');
      expect(ca.currencySymbol, r'$');
    });

    test('labelFor follows locale language', () {
      const frLocale = Locale('fr', 'FR');
      const enLocale = Locale('en', 'US');
      expect(MarketConfig.labelFor('BE', frLocale), 'Belgique');
      expect(MarketConfig.labelFor('BE', enLocale), 'Belgium');
    });
  });
}

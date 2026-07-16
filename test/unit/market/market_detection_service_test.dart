import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/services/location/market_detection_service.dart';

void main() {
  group('MarketDetectionService.countryFromLocale', () {
    test('uses locale country code when supported', () {
      expect(
        MarketDetectionService.countryFromLocale(
          locale: const Locale('fr', 'BE'),
        ),
        'BE',
      );
      expect(
        MarketDetectionService.countryFromLocale(
          locale: const Locale('en', 'CA'),
        ),
        'CA',
      );
    });

    test('does not force FR for French language without country', () {
      // Ambigu (FR/BE/CA/CH) — le GPS doit trancher sur mobile.
      expect(
        MarketDetectionService.tryCountryFromLocale(
          locale: const Locale('fr'),
        ),
        isNull,
      );
      expect(
        MarketDetectionService.countryFromLocale(
          locale: const Locale('fr'),
        ),
        'FR', // fallback explicite uniquement
      );
    });

    test('returns null for unsupported locale country', () {
      expect(
        MarketDetectionService.tryCountryFromLocale(
          locale: const Locale('en', 'US'),
        ),
        isNull,
      );
      expect(
        MarketDetectionService.countryFromLocale(
          locale: const Locale('en', 'US'),
          fallback: 'FR',
        ),
        'FR',
      );
    });
  });
}

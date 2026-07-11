import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/logic/market/market_country_resolver.dart';
import 'package:madbeauty/services/storage/local_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalCacheService.initialize();
  });

  const unsupportedLocale = Locale('en', 'US');

  group('MarketCountryResolver', () {
    test('prefers auto code over manual and profile', () async {
      final cache = LocalCacheService.instance;
      await cache.setMarketCountryAutoCode('BE');
      await cache.setMarketCountryManual(true);
      await cache.setMarketCountryManualCode('FR');

      expect(
        MarketCountryResolver.resolve(
          cache: cache,
          profileCountryCode: 'CA',
          localeForAuto: unsupportedLocale,
        ),
        'BE',
      );
    });

    test('uses locale auto before manual choice', () {
      final cache = LocalCacheService.instance;

      expect(
        MarketCountryResolver.resolve(
          cache: cache,
          profileCountryCode: 'CA',
          localeForAuto: const Locale('fr', 'BE'),
        ),
        'BE',
      );
    });

    test('uses manual when auto cache empty and locale unsupported', () async {
      final cache = LocalCacheService.instance;
      await cache.setMarketCountryManual(true);
      await cache.setMarketCountryManualCode('CA');

      expect(
        MarketCountryResolver.resolve(
          cache: cache,
          profileCountryCode: 'FR',
          localeForAuto: unsupportedLocale,
        ),
        'CA',
      );
    });

    test('falls back to profile when auto and manual absent', () {
      final cache = LocalCacheService.instance;

      expect(
        MarketCountryResolver.resolve(
          cache: cache,
          profileCountryCode: 'BE',
          localeForAuto: unsupportedLocale,
        ),
        'BE',
      );
    });
  });
}

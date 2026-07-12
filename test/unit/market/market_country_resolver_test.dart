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
    test('prefers profile address over auto and manual', () async {
      final cache = LocalCacheService.instance;
      await cache.setMarketCountryAutoCode('FR');
      await cache.setMarketCountryManual(true);
      await cache.setMarketCountryManualCode('FR');

      expect(
        MarketCountryResolver.resolve(
          cache: cache,
          profileCountryCode: 'BE',
          localeForAuto: unsupportedLocale,
        ),
        'BE',
      );
    });

    test('prefers auto code over manual without profile', () async {
      final cache = LocalCacheService.instance;
      await cache.setMarketCountryAutoCode('BE');
      await cache.setMarketCountryManual(true);
      await cache.setMarketCountryManualCode('FR');

      expect(
        MarketCountryResolver.resolve(
          cache: cache,
          profileCountryCode: null,
          localeForAuto: unsupportedLocale,
        ),
        'BE',
      );
    });

    test('uses locale auto before manual choice without profile', () {
      final cache = LocalCacheService.instance;

      expect(
        MarketCountryResolver.resolve(
          cache: cache,
          profileCountryCode: null,
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
          profileCountryCode: null,
          localeForAuto: unsupportedLocale,
        ),
        'CA',
      );
    });

    test('falls back to default when profile auto and manual absent', () {
      final cache = LocalCacheService.instance;

      expect(
        MarketCountryResolver.resolve(
          cache: cache,
          profileCountryCode: null,
          localeForAuto: unsupportedLocale,
        ),
        'FR',
      );
    });
  });
}

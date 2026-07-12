import 'package:flutter/widgets.dart';

import '../../config/market_config.dart';
import '../../../services/location/market_detection_service.dart';
import '../../../services/storage/local_cache_service.dart';

/// Priorité marché : adresse profil client → auto (locale/GPS) → choix manuel → défaut.
abstract final class MarketCountryResolver {
  MarketCountryResolver._();

  static String resolve({
    required LocalCacheService cache,
    String? profileCountryCode,
    Locale? localeForAuto,
  }) {
    _migrateLegacyMarketCountry(cache);

    final profile = profileCountryCode?.trim();
    if (profile != null && profile.isNotEmpty) {
      return MarketConfig.normalizeCountryCode(profile);
    }

    final autoCached = cache.marketCountryAutoCode?.trim();
    if (autoCached != null && autoCached.isNotEmpty) {
      return MarketConfig.normalizeCountryCode(autoCached);
    }

    final fromLocale = MarketDetectionService.tryCountryFromLocale(
      locale: localeForAuto,
    );
    if (fromLocale != null && MarketConfig.isSupported(fromLocale)) {
      return fromLocale;
    }

    if (cache.marketCountryManual) {
      final manual = cache.marketCountryManualCode?.trim();
      if (manual != null && manual.isNotEmpty) {
        return MarketConfig.normalizeCountryCode(manual);
      }
    }

    return MarketConfig.defaultCountryCode;
  }

  static void _migrateLegacyMarketCountry(LocalCacheService cache) {
    final legacy = cache.marketCountryCode?.trim();
    if (legacy == null || legacy.isEmpty) return;

    if (cache.marketCountryAutoCode?.trim().isNotEmpty == true &&
        cache.marketCountryManualCode?.trim().isNotEmpty == true) {
      return;
    }

    if (cache.marketCountryManual && cache.marketCountryManualCode == null) {
      cache.setMarketCountryManualCode(legacy);
    } else if (cache.marketCountryAutoDetected &&
        cache.marketCountryAutoCode == null) {
      cache.setMarketCountryAutoCode(legacy);
    }
  }
}

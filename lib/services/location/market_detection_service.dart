import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';

import '../../core/config/market_config.dart';
import '../../core/geo/geo_point.dart';
import 'geocoding_service.dart';
import 'geolocation_service.dart';

/// Détection automatique du marché (pays) sans interaction utilisateur.
class MarketDetectionService {
  MarketDetectionService({
    GeolocationService? geolocation,
    GeocodingService? geocoding,
  }) : _geolocation = geolocation ?? GeolocationService(),
       _geocoding = geocoding ?? GeocodingService();

  final GeolocationService _geolocation;
  final GeocodingService _geocoding;

  static const _detectTimeout = Duration(seconds: 6);

  /// Pays depuis la locale si la détection est fiable ; sinon `null`.
  static String? tryCountryFromLocale({Locale? locale}) {
    final loc = locale ?? PlatformDispatcher.instance.locale;
    final country = loc.countryCode?.trim().toUpperCase();
    if (country != null &&
        country.length == 2 &&
        MarketConfig.isSupported(country)) {
      return country;
    }

    return switch (loc.languageCode) {
      'fr' => MarketConfig.defaultCountryCode,
      'de' => 'DE',
      'en' when country == 'CA' => 'CA',
      'en' when country == 'GB' => 'GB',
      _ => null,
    };
  }

  /// Pays depuis la locale appareil / navigateur (instantané, sans permission).
  static String countryFromLocale({
    Locale? locale,
    String fallback = MarketConfig.defaultCountryCode,
  }) {
    return tryCountryFromLocale(locale: locale) ?? fallback;
  }

  /// GPS (si déjà autorisé) puis locale. Ne demande jamais la permission.
  /// Retourne `null` si aucune détection fiable (locale/GPS).
  Future<String?> tryDetect({Locale? locale}) async {
    try {
      return await _detectInternal(locale: locale).timeout(
        _detectTimeout,
        onTimeout: () => tryCountryFromLocale(locale: locale),
      );
    } on Object {
      return tryCountryFromLocale(locale: locale);
    }
  }

  Future<String> detect({
    Locale? locale,
    String fallback = MarketConfig.defaultCountryCode,
  }) async {
    return await tryDetect(locale: locale) ??
        countryFromLocale(locale: locale, fallback: fallback);
  }

  Future<String?> _detectInternal({Locale? locale}) async {
    final location = await _geolocation.getCurrentLocationIfPermitted();
    if (location != null) {
      final fromGps = await _geocoding.reverseGeocodeCountryIso(
        GeoPoint(
          latitude: location.latitude,
          longitude: location.longitude,
        ),
      );
      if (fromGps != null && MarketConfig.isSupported(fromGps)) {
        return fromGps;
      }
    }

    return tryCountryFromLocale(locale: locale);
  }
}

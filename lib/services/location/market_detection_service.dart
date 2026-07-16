import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart' show kIsWeb;
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

  static const _detectTimeout = Duration(seconds: 8);

  /// Pays depuis la locale si la détection est fiable ; sinon `null`.
  ///
  /// Parcourt toutes les locales appareil (pas seulement la primaire) : sur
  /// mobile francophone, la locale principale est souvent `fr` / `fr_FR` alors
  /// qu’une locale secondaire porte le vrai pays (`fr_BE`, `fr_CA`).
  static String? tryCountryFromLocale({Locale? locale}) {
    final candidates = <Locale>[
      if (locale != null) locale,
      PlatformDispatcher.instance.locale,
      ...PlatformDispatcher.instance.locales,
    ];

    for (final loc in candidates) {
      final country = loc.countryCode?.trim().toUpperCase();
      if (country != null &&
          country.length == 2 &&
          MarketConfig.isSupported(country)) {
        return country;
      }
    }

    // Langue seule : signal faible. Ne pas forcer FR pour tout téléphone
    // francophone (Belgique / Canada / Suisse utilisent souvent `fr` sans région).
    final primary = locale ?? PlatformDispatcher.instance.locale;
    return switch (primary.languageCode) {
      'de' => 'DE',
      'en' => null, // trop ambigu sans region
      'fr' => null, // trop ambigu (FR/BE/CA/CH)
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

  /// Pays ISO depuis une position GPS déjà connue.
  Future<String?> countryFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final iso = await _geocoding.reverseGeocodeCountryIso(
        GeoPoint(latitude: latitude, longitude: longitude),
      );
      if (iso != null && MarketConfig.isSupported(iso)) return iso;
      return null;
    } on Object {
      return null;
    }
  }

  /// GPS (si déjà autorisé, ou avec demande si [requestPermission]) puis locale.
  /// Retourne `null` si aucune détection fiable.
  Future<String?> tryDetect({
    Locale? locale,
    bool requestPermission = false,
  }) async {
    try {
      return await _detectInternal(
        locale: locale,
        requestPermission: requestPermission,
      ).timeout(
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
    bool requestPermission = false,
  }) async {
    return await tryDetect(
          locale: locale,
          requestPermission: requestPermission,
        ) ??
        countryFromLocale(locale: locale, fallback: fallback);
  }

  Future<String?> _detectInternal({
    Locale? locale,
    bool requestPermission = false,
  }) async {
    // Sur mobile, si aucune permission encore : demander une fois pour
    // distinguer FR / BE / CA (la locale `fr` seule est ambiguë).
    final shouldAsk =
        requestPermission || (!kIsWeb && !_localeHasSupportedCountry(locale));

    final location = shouldAsk
        ? await _geolocation.getCurrentLocation()
        : await _geolocation.getCurrentLocationIfPermitted();

    if (location != null) {
      final fromGps = await countryFromCoordinates(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      if (fromGps != null) return fromGps;
    }

    return tryCountryFromLocale(locale: locale);
  }

  static bool _localeHasSupportedCountry(Locale? locale) {
    return tryCountryFromLocale(locale: locale) != null;
  }
}

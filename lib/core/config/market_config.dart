import 'package:flutter/material.dart';

/// Marché géographique MadBeauty (ISO 3166-1 alpha-2).
class MarketDefinition {
  const MarketDefinition({
    required this.isoCode,
    required this.labelFr,
    required this.labelEn,
    required this.currencyCode,
    required this.currencySymbol,
  });

  final String isoCode;
  final String labelFr;
  final String labelEn;
  final String currencyCode;
  final String currencySymbol;

  String labelFor(Locale locale) =>
      locale.languageCode == 'en' ? labelEn : labelFr;
}

/// Pays supportés et marché par défaut.
abstract final class MarketConfig {
  MarketConfig._();

  static const defaultCountryCode = 'FR';

  static const List<MarketDefinition> supportedMarkets = [
    MarketDefinition(
      isoCode: 'FR',
      labelFr: 'France',
      labelEn: 'France',
      currencyCode: 'EUR',
      currencySymbol: '€',
    ),
    MarketDefinition(
      isoCode: 'BE',
      labelFr: 'Belgique',
      labelEn: 'Belgium',
      currencyCode: 'EUR',
      currencySymbol: '€',
    ),
    MarketDefinition(
      isoCode: 'CA',
      labelFr: 'Canada',
      labelEn: 'Canada',
      currencyCode: 'CAD',
      currencySymbol: r'$',
    ),
    MarketDefinition(
      isoCode: 'CH',
      labelFr: 'Suisse',
      labelEn: 'Switzerland',
      currencyCode: 'CHF',
      currencySymbol: 'CHF',
    ),
    MarketDefinition(
      isoCode: 'DE',
      labelFr: 'Allemagne',
      labelEn: 'Germany',
      currencyCode: 'EUR',
      currencySymbol: '€',
    ),
    MarketDefinition(
      isoCode: 'GB',
      labelFr: 'Royaume-Uni',
      labelEn: 'United Kingdom',
      currencyCode: 'GBP',
      currencySymbol: '£',
    ),
  ];

  static final Map<String, MarketDefinition> _byIso = {
    for (final m in supportedMarkets) m.isoCode: m,
  };

  static bool isSupported(String? isoCode) {
    final code = isoCode?.trim().toUpperCase();
    if (code == null || code.isEmpty || code.length != 2) return false;
    return _byIso.containsKey(code);
  }

  static String normalizeCountryCode(String? raw) {
    final value = raw?.trim().toUpperCase();
    if (value == null || value.isEmpty) return defaultCountryCode;
    if (value.length == 2 && _byIso.containsKey(value)) return value;
    return switch (value) {
      'FRANCE' => 'FR',
      'BELGIQUE' || 'BELGIUM' => 'BE',
      'CANADA' => 'CA',
      'SUISSE' || 'SWITZERLAND' => 'CH',
      'ALLEMAGNE' || 'GERMANY' => 'DE',
      'ROYAUME-UNI' || 'UNITED KINGDOM' || 'UK' => 'GB',
      _ => defaultCountryCode,
    };
  }

  static MarketDefinition definitionFor(String? isoCode) {
    final code = normalizeCountryCode(isoCode);
    return _byIso[code] ?? _byIso[defaultCountryCode]!;
  }

  static String labelFor(String? isoCode, Locale locale) =>
      definitionFor(isoCode).labelFor(locale);
}

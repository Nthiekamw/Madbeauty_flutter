import '../../../core/config/market_config.dart';

/// Pays proposés dans [PostalAddressForm] (select au-dessus de la recherche rapide).
const List<String> postalFormCountryIsoCodes = ['FR', 'CA', 'BE'];

bool isPostalFormCountry(String? isoCode) {
  final code = isoCode?.trim().toUpperCase();
  if (code == null || code.isEmpty) return false;
  return postalFormCountryIsoCodes.contains(code);
}

/// Code ISO2 restreint aux pays du formulaire d'adresse.
String postalFormCountryIso2(String? raw) {
  final iso = postalCountryIso2(raw);
  return isPostalFormCountry(iso) ? iso : MarketConfig.defaultCountryCode;
}

/// Libellé pays affiché dans [PostalAddressForm] depuis un code ISO ou libellé.
String postalCountryLabelForIso(String? iso) {
  final code = MarketConfig.normalizeCountryCode(
    iso?.trim().isEmpty == true ? null : iso,
  );
  return MarketConfig.definitionFor(code).labelFr;
}

/// Code ISO2 pour la base à partir du libellé ou code saisi.
String postalCountryIso2(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return MarketConfig.defaultCountryCode;
  if (value.length == 2) {
    final upper = value.toUpperCase();
    return MarketConfig.isSupported(upper) ? upper : MarketConfig.defaultCountryCode;
  }
  return MarketConfig.normalizeCountryCode(value);
}

import '../../config/market_config.dart';
import '../../models/domain/catalog/prestataire_catalog_entry.dart';
import '../../models/domain/user/prestataire_profile.dart';

/// Prestataire éligible au marché actif (pays ISO).
bool prestataireProfileMatchesMarket(
  PrestataireProfile profile,
  String marketCountry,
) {
  final code = MarketConfig.normalizeCountryCode(marketCountry);
  final rawPays = profile.pays?.trim();
  if (rawPays == null || rawPays.isEmpty) {
    return code == MarketConfig.defaultCountryCode;
  }
  final profileCountry = MarketConfig.normalizeCountryCode(rawPays);
  return profileCountry == code;
}

List<PrestataireCatalogEntry> filterCatalogEntriesByMarket(
  List<PrestataireCatalogEntry> entries,
  String marketCountry,
) {
  return entries
      .where((e) => prestataireProfileMatchesMarket(e.profile, marketCountry))
      .toList(growable: false);
}

List<PrestataireProfile> filterPrestataireProfilesByMarket(
  List<PrestataireProfile> profiles,
  String marketCountry,
) {
  return profiles
      .where((p) => prestataireProfileMatchesMarket(p, marketCountry))
      .toList(growable: false);
}

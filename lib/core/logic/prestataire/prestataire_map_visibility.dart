import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';

/// Règles d’éligibilité carte (complément au filtre SQL [prestataire_is_map_visible]).
extension PrestataireCatalogEntryMap on PrestataireCatalogEntry {
  bool get hasGeoCoordinates {
    final la = profile.latitude;
    final lo = profile.longitude;
    return la != null && lo != null;
  }

  bool get isEligibleForMap => hasGeoCoordinates;
}

List<PrestataireCatalogEntry> filterMapCatalogEntries(
  List<PrestataireCatalogEntry> entries,
) {
  return entries.where((e) => e.isEligibleForMap).toList(growable: false);
}

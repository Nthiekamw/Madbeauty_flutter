import '../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../models/home_feed_selection.dart';

bool matchesHomeMainService(
  PrestataireCatalogEntry entry,
  PrestaMainService main,
) {
  final categoryIds = PrestataireServiceCatalog.specialties(main)
      .map((s) => s.categoryId)
      .whereType<String>()
      .toSet();
  final specialtyLabels = PrestataireServiceCatalog.specialties(main)
      .map((s) => s.label.toLowerCase())
      .toSet();
  final mainLabel = PrestataireServiceCatalog.label(main).toLowerCase();

  if (entry.specialtyCategoryIds.any(categoryIds.contains)) return true;
  for (final name in entry.specialtyNames) {
    final lower = name.toLowerCase();
    if (specialtyLabels.contains(lower)) return true;
    if (lower.contains(mainLabel)) return true;
  }
  return false;
}

/// Filtre « Proches » / « Mieux notés » selon inspiration ou recherche accueil.
List<PrestataireCatalogEntry> filterCatalogEntriesForHomeSelection(
  List<PrestataireCatalogEntry> entries,
  HomeFeedSelection? selection,
) {
  if (selection == null) return entries;

  var out = entries;

  if (selection.mainService != null) {
    final main = selection.mainService!;
    out = out.where((e) => matchesHomeMainService(e, main)).toList();
  }

  if (selection.source == HomeFeedSource.search && selection.query.trim().isNotEmpty) {
    out = out.where((e) => e.matchesSearch(selection.query)).toList();
  }

  return out;
}

bool homeSelectionFiltersNearbyOrTopRated(HomeFeedSelection? selection) {
  if (selection == null) return false;
  if (selection.mainService != null) return true;
  return selection.source == HomeFeedSource.search &&
      selection.query.trim().isNotEmpty;
}

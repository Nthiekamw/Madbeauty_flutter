/// Liste / filtres catalogue prestataires.
abstract final class DiscList {
  DiscList._();

  static const searchSubtitle =
      'Filtre par salon, ville ou type de prestation.';
  static const categoriesLabel = 'Catégories';
  static const filtersQuickLabel = 'Filtres rapides';
  static const specialtyFiltersTitle = 'Spécialités';
  static const resultsFilteredTitle = 'Résultats';
  static const resultsDiscoverTitle = 'À découvrir';
  static const quickFiltersTitle = 'Explorer par style';
  static const quickFiltersSub =
      'Les mêmes univers que sur l’accueil : tresses, locks, coupe…';
  static const quickFiltersReset = 'Effacer';
  static const citiesFilterTitle = 'Par ville';
  static const advancedFiltersTitle = 'Affichage & filtres';
  static const filtersTitle = 'Filtres';
  static const hintSearch =
      'Filtrer par salon, ville, type de service (coiffure, manucure, maquillage…)…';

  static String resultsCount(int count) {
    if (count <= 0) return 'Aucun résultat';
    if (count == 1) return '1 prestataire';
    return '$count prestataires';
  }
  static const chipAll = 'Tout';
  static const modeList = 'Liste';
  static const modeMap = 'Carte';
  static const layoutSectionTitle = 'Format des cartes';
  static const layoutExpanded = 'Étendu';
  static const layoutGrid = 'Grille';
  static const filtersDone = 'Terminé';
  static const layoutExpandedHint =
      'Cartes pleine largeur avec plus de détails';
  static const layoutGridHint = 'Deux colonnes, aperçu rapide';
  static const sortLabel = 'Trier par';
  static const sortRating = 'Note';
  static const sortDistance = 'Distance';
  static const svcTypeLabel = 'Type de service';
  static const mapNoGeo =
      'Aucun prestataire géolocalisé dans ces résultats.';
  static const mapNoGeoHint =
      'Les prestataires doivent renseigner latitude et longitude pour apparaître sur la carte.';
  static const mapOpenDetail = 'Voir la fiche';
  static const mapDirections = 'Itinéraire';
  static const mapDirectionsOpenExternal = 'Ouvrir dans Maps';
  static const mapDirectionsLoading = 'Calcul de l’itinéraire…';
  static const mapDirectionsNeedLocation =
      'Active ta localisation pour voir le trajet sur la carte.';
  static const mapDirectionsOpenFailed =
      'Impossible d’ouvrir Maps. Réessaie dans un instant.';
  static String mapRouteDistanceKm(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    if (km < 10) return '${km.toStringAsFixed(1)} km';
    return '${km.round()} km';
  }

  static String mapRouteDuration(Duration d) {
    final totalMin = d.inMinutes;
    if (totalMin < 1) return '< 1 min';
    if (totalMin < 60) return '$totalMin min';
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    if (m == 0) return '${h} h';
    return '${h} h ${m} min';
  }

  static String mapRouteSummary({
    required double distanceKm,
    required Duration duration,
    required bool approximate,
  }) {
    final base =
        '${mapRouteDistanceKm(distanceKm)} · ${mapRouteDuration(duration)}';
    return approximate ? '$base (approx.)' : base;
  }

  static const mapExpandHint = 'Agrandir la carte';
  static const mapCollapseHint = 'Réduire la carte';
  static const emptyFilterTitle =
      'Aucun prestataire trouvé pour ces critères';
  static const emptyFilterHint =
      'Modifie ta recherche ou retire un filtre de type de service.';
  static const emptyCatalogTitle =
      'Aucun prestataire dans le catalogue pour l’instant.';
  static const pullDownHint = 'Tire vers le bas pour actualiser.';
  static const catalogLoadErr =
      'Impossible de charger le catalogue. Réessaie.';
  static const retry = 'Réessayer';
  static const seeMore = 'Voir plus';
  static const allPrestatairesTitle = 'Tous les prestataires';
  static const loadMoreErr = 'Impossible de charger la suite. Réessaie.';
  static const refreshErr =
      'Impossible d’actualiser le catalogue. Réessaie.';
}

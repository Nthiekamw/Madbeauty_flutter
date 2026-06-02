/// Liste / filtres catalogue prestataires.
abstract final class DiscList {
  DiscList._();

  static const searchSubtitle =
      'Filtre par salon, ville ou type de prestation.';
  static const quickFiltersTitle = 'Explorer par style';
  static const quickFiltersSub =
      'Les mêmes univers que sur l’accueil : tresses, locks, coupe…';
  static const quickFiltersReset = 'Effacer';
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
  static const layoutExpanded = 'Étendu';
  static const layoutGrid = 'Grille';
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
  static const emptyFilterTitle = 'Aucun prestataire ne correspond à ta recherche.';
  static const emptyFilterHint =
      'Modifie ta recherche ou retire un filtre de type de service.';
  static const emptyCatalogTitle =
      'Aucun prestataire dans le catalogue pour l’instant.';
  static const pullDownHint = 'Tire vers le bas pour actualiser.';
  static const catalogLoadErr =
      'Impossible de charger le catalogue. Réessaie.';
  static const retry = 'Réessayer';
  static const seeMore = 'Voir plus';
  static const loadMoreErr = 'Impossible de charger la suite. Réessaie.';
  static const refreshErr =
      'Impossible d’actualiser le catalogue. Réessaie.';
}

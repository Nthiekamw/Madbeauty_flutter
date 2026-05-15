/// Liste / filtres catalogue prestataires.
abstract final class DiscList {
  DiscList._();

  static const hintSearch =
      'Filtrer par salon, ville, type de service (coiffure, manucure, maquillage…)…';
  static const chipAll = 'Tout';
  static const modeList = 'Liste';
  static const modeMap = 'Carte';
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

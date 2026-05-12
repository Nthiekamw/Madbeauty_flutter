/// Titres d’écrans stub, accueil client, listing / recherche.
abstract final class DiscoveryStrings {
  DiscoveryStrings._();

  static const String screenPrestataireHub = 'Espace prestataire';
  static const String screenListing = 'Prestataires';
  static const String screenSearch = 'Recherche';
  static const String screenBooking = 'Réservations';
  static const String screenMessaging = 'Messages';
  static const String screenStats = 'Statistiques';
  static const String screenProfile = 'Profil';
  static const String screenReviews = 'Avis';

  static const String listingSearchHint =
      'Filtrer par salon, ville, type de service (coiffure, manucure, maquillage…)…';
  static const String listingChipAll = 'Tout';
  static const String listingSortLabel = 'Trier par';
  static const String listingSortRating = 'Note';
  static const String listingSortDistance = 'Distance';
  static const String listingServicesLabel = 'Type de service';
  static const String listingFilterEmpty =
      'Aucun prestataire ne correspond à ta recherche.';
  static const String listingFilterEmptyHint =
      'Modifie ta recherche ou retire un filtre de type de service.';
  static const String listingCatalogEmpty =
      'Aucun prestataire dans le catalogue pour l’instant.';
  static const String listingPullToRefreshHint =
      'Tire vers le bas pour actualiser.';
  static const String listingCatalogLoadError =
      'Impossible de charger le catalogue. Réessaie.';
  static const String listingRetry = 'Réessayer';
  static const String listingSeeMore = 'Voir plus';
  static const String listingLoadMoreError =
      'Impossible de charger la suite. Réessaie.';
  static const String listingRefreshError =
      'Impossible d’actualiser le catalogue. Réessaie.';

  static const String homeClientSearchHint =
      'Rechercher un style, une ville, un pseudo…';
  static const String homeClientSearchAction = 'Rechercher';
  static const String homeClientDiscoveryLine =
      'Découvre des pros près de chez toi et réserve en quelques gestes.';
  static const String homeClientExploreTitle = 'Inspirations';
  static const String homeClientExploreSubtitle =
      'Un tap pour ouvrir le listing avec ce thème.';

  static const String homeNearbyPrestatairesTitle = 'Prestataires proches';
  static const String homeNearbyPrestatairesSubtitle =
      'Tri par distance (référence Paris) — ta position remplacera ce repère plus tard.';
  static const String homeNearbyPrestatairesEmptyTitle = 'Aucun prestataire proche';
  static const String homeNearbyPrestatairesEmptyBody =
      'Aucun profil ne correspond encore : base vide ou personne n’a renseigné sa position. '
      'Tu peux parcourir tout le catalogue.';
  static const String homeNearbyPrestatairesLoadError =
      'Impossible de charger les prestataires. Réessaie.';

  static const String homeTopRatedTitle = 'Mieux notés';
  static const String homeTopRatedSubtitle =
      'Triés par note moyenne (les profils sans note encore en bas de liste).';
  static const String homeTopRatedEmptyTitle = 'Pas encore de classement';
  static const String homeTopRatedEmptyBody =
      'Aucune note moyenne enregistrée pour l’instant. Ouvre le catalogue pour découvrir les salons.';
  static const String homePrestatairesEmptyCta = 'Voir le catalogue';

  static const String prestataireDetailScreenTitle = 'Prestataire';
  static const String prestataireDetailNotFound =
      'Ce profil n’existe pas ou n’est plus disponible.';
  static const String prestataireDetailLoadError =
      'Impossible de charger cette fiche. Réessaie.';
  static const String prestataireDetailVerified = 'Profil vérifié';
  static const String prestataireDetailBioTitle = 'À propos';

  /// [km] distance affichée (Haversine).
  static String homeNearbyPrestatairesDistanceKm(double km) {
    if (km.isInfinite || km.isNaN) return '';
    final decimals = km < 10 ? 1 : 0;
    return '≈ ${km.toStringAsFixed(decimals)} km';
  }

  /// [displayName] : nom complet ou vide (on affiche alors « Bonjour » seul).
  static String homeClientGreeting(String displayName) {
    final t = displayName.trim();
    if (t.isEmpty) return 'Bonjour';
    final first = t.split(RegExp(r'\s+')).first;
    return 'Bonjour, $first';
  }
}

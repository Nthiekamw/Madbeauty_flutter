/// Accueil client.
abstract final class DiscHome {
  DiscHome._();

  static const hintSearch =
      'Rechercher un style, une ville, un pseudo…';
  static const actionSearch = 'Rechercher';
  static const taglineDiscovery =
      'Découvre des pros près de chez toi et réserve en quelques gestes.';
  static const inspireTitle = 'Inspirations';
  static const inspireSub =
      'Choisis un thème pour afficher des prestataires.';

  static const feedSearchSub =
      'Prestataires correspondant à votre recherche.';
  static const feedInspirationSub =
      'Prestataires pour ce thème.';
  static const feedEmptyTitle = 'Aucun résultat';
  static const feedEmptyBody =
      'Essayez un autre mot-clé ou parcourez le catalogue.';
  static const feedLoadFail =
      'Impossible de charger les résultats. Réessaie.';

  static const notificationsTooltip = 'Notifications';
  static const notificationsComingSoon =
      'Les notifications arrivent bientôt.';

  static String feedSearchTitle(String query) =>
      'Résultats pour « $query »';

  static String feedInspirationTitle(String topic) =>
      'Inspiration · $topic';

  static const nearbyTitle = 'Prestataires proches';
  static const nearbySubWithLocation =
      'Triés par distance depuis ta position (rayon 50 km).';
  static const nearbySubNoLocation =
      'Active la localisation pour voir les pros autour de toi. En attendant, tri depuis Paris.';
  static const nearbyEmptyTitle = 'Aucun prestataire proche';
  static const nearbyEmptyBody =
      'Aucun profil ne correspond encore : base vide ou personne n’a renseigné sa position. '
      'Tu peux parcourir tout le catalogue.';
  static const nearbyLoadFail =
      'Impossible de charger les prestataires. Réessaie.';

  static const topRatedTitle = 'Mieux notés';
  static const topRatedSub =
      'Triés par note moyenne (les profils sans note encore en bas de liste).';
  static const topRatedEmptyTitle = 'Pas encore de classement';
  static const topRatedEmptyBody =
      'Aucune note moyenne enregistrée pour l’instant. Ouvre le catalogue pour découvrir les salons.';
  static const ctaBrowseCatalog = 'Voir le catalogue';
  static const ctaSeeAll = 'Tout voir';
  static const badgeDispo = 'Dispo';
  static const badgeNonDispo = 'Non dispo';

  /// Distance affichée (Haversine, [km]).
  static String nearbyKm(double km) {
    if (km.isInfinite || km.isNaN) return '';
    final decimals = km < 10 ? 1 : 0;
    return '≈ ${km.toStringAsFixed(decimals)} km';
  }

  /// [displayName] : nom ou vide (« Bonjour » seul).
  static String greeting(String displayName) {
    final t = displayName.trim();
    if (t.isEmpty) return 'Bonjour';
    final first = t.split(RegExp(r'\s+')).first;
    return 'Bonjour, $first';
  }
}

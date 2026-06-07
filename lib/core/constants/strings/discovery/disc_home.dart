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
      'Filtrez par service pour afficher des prestataires.';
  static const filterAll = 'Toutes';

  static const feedAllTitle = 'À découvrir';
  static const feedAllSub =
      'Des professionnels passionnés, prêts à vous accueillir.';

  static const nextAppointmentTitle = 'Vos prochains rendez-vous';
  static const nextAppointmentSub = 'Ta prochaine visite chez un·e pro';
  static const nextAppointmentDetails = 'Voir détails';
  static const nextAppointmentEmptyTitle = 'Aucun rendez-vous à venir';
  static const nextAppointmentEmptyBody =
      'Parcours le catalogue pour réserver ta prochaine séance.';
  static const nextAppointmentCta = 'Réserver';
  static const nextAppointmentSeeAll = 'Mes réservations';

  static const layoutOrganizeAction = 'Organiser';
  static const layoutCustomizeTitle = 'Organiser l\'accueil';
  static const layoutCustomizeHint =
      'Glisse les sections pour changer leur ordre.';
  static const layoutModalDone = 'Terminé';

  static const sectionNextAppointment = 'Prochain rendez-vous';
  static const sectionInspiration = 'Inspirations';
  static const sectionFeed = 'À découvrir';
  static const sectionNearby = 'Prestataires proches';
  static const sectionTopRated = 'Mieux notés';

  static const feedSearchSub =
      'Prestataires correspondant à votre recherche.';
  static const feedInspirationSub =
      'Les pros qui correspondent à votre sélection.';
  static const feedEmptyTitle = 'Aucun résultat';
  static const feedEmptyBody =
      'Essayez un autre mot-clé ou parcourez le catalogue.';
  static const feedLoadFail =
      'Impossible de charger les résultats. Réessaie.';

  static const notificationsTooltip = 'Notifications';
  static const notificationsComingSoon =
      'Les notifications arrivent bientôt.';

  static String feedSearchTitle(String query) =>
      'Salons pour « $query »';

  static String feedInspirationTitle(String topic) => 'En $topic';

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
    return '${km.toStringAsFixed(decimals)} km';
  }

  static String ratingWithReviews(double rating, int? reviewCount) {
    final score = rating.toStringAsFixed(1);
    if (reviewCount == null || reviewCount <= 0) return score;
    return '$score ($reviewCount avis)';
  }

  static String clientHomeGreeting(String firstName) {
    final name = firstName.trim();
    if (name.isEmpty) {
      return 'Salut, envie de vous sublimer de la tête aux pieds 👋';
    }
    return 'Salut $name, envie de vous sublimer de la tête aux pieds 👋';
  }
}

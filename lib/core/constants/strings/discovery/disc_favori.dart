/// Favoris prestataires (client).
abstract final class DiscFavori {
  DiscFavori._();

  static const screenTitle = 'Mes favoris';
  static const profileSectionTitle = 'Mes favoris';
  static const profileEmptyHint =
      'Enregistre tes prestataires préférés pour les retrouver ici.';
  static String profileCountHint(int count) =>
      count == 1 ? '1 prestataire enregistré' : '$count prestataires enregistrés';
  static const emptyTitle = 'Aucun favori pour l’instant';
  static const emptyBody =
      'Appuie sur le cœur d’un prestataire pour le retrouver ici rapidement.';
  static const loginRequired =
      'Connecte-toi pour enregistrer tes prestataires favoris.';
  static const toggleError =
      'Impossible de mettre à jour les favoris. Réessaie.';
  static const favoriteTooltip = 'Ajouter aux favoris';
  static const unfavoriteTooltip = 'Retirer des favoris';
}

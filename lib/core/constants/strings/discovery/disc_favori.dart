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
      'Appuie sur Enregistrer (signet) sur une fiche prestataire pour la '
      'garder dans ta liste privée.';
  static const loginRequired =
      'Connecte-toi pour enregistrer tes prestataires favoris.';
  static const toggleError =
      'Impossible de mettre à jour les favoris. Réessaie.';
  static const loadErrorTitle = 'Impossible de charger vos favoris';
  static const loadErrorBody =
      'Vérifiez votre connexion et réessayez.';
  static const favoriteTooltip = 'Enregistrer dans Mes favoris';
  static const unfavoriteTooltip = 'Retirer de Mes favoris';
  static const addedFeedback =
      'Prestataire enregistré dans Mes favoris (liste privée).';
  static const removedFeedback = 'Prestataire retiré de Mes favoris.';
  static const engagementLabel = 'Enregistrer';
  static const engagementHint =
      'Liste privée · pour retrouver ce prestataire plus tard';
}

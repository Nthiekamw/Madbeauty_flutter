/// Likes prestataire (client → prestataire).
abstract final class DiscLike {
  DiscLike._();

  static const loginRequired =
      'Connecte-toi pour aimer un prestataire.';
  static const toggleError =
      'Impossible de mettre à jour le like. Réessaie.';
  static const likeTooltip = 'Aimer ce profil';
  static const unlikeTooltip = 'Retirer mon like';
  static const statLikes = 'Likes';
  static const addedFeedback =
      'Like envoyé · le/la pro est notifié(e) et voit ton soutien.';
  static const removedFeedback = 'Like retiré.';
  static const engagementLabel = 'Aimer';
  static const engagementHint =
      'Soutien public · le/la pro reçoit une notification';
  static const filterPreferred = 'Mes préférés';
}

/// Chaînes UI — feed Reel (client + publication presta).
abstract final class DiscReel {
  DiscReel._();

  static const navLabel = 'Reel';
  static const feedTitle = 'Reel';
  static const feedEmptyTitle = 'Aucun Reel pour le moment';
  static const feedEmptyBody =
      'Les salons valides publieront bientôt photos et vidéos ici.';
  static const feedLoadError = 'Impossible de charger les Reels.';
  static const retry = 'Réessayer';
  static const seeSalon = 'Voir le salon';
  static const bookCta = 'Réserver';
  static const likeTooltip = 'J’aime';
  static const unlikeTooltip = 'Retirer le j’aime';
  static const likeLoginRequired = 'Connecte-toi pour aimer un Reel.';
  static const likeError = 'Impossible de mettre à jour le j’aime.';
  static const captionFallback = '';

  static const menuTitle = 'Mes Reels';
  static const menuHint = 'Publie photos et vidéos pour tes clientes';
  static const manageTitle = 'Mes Reels';
  static const manageEmptyTitle = 'Aucun Reel publié';
  static const manageEmptyBody =
      'Ajoute une photo ou une vidéo pour apparaître dans le fil Reel.';
  static const manageLoadError = 'Impossible de charger tes Reels.';
  static const publishCta = 'Nouveau Reel';
  static const publishTitle = 'Publier un Reel';
  static const publishCaptionLabel = 'Légende (optionnel)';
  static const publishCaptionHint = 'Ex. : Soft glam pour un mariage…';
  static const publishPickMedia = 'Choisir photo ou vidéo';
  static const publishSubmit = 'Publier';
  static const publishSuccess = 'Reel publié.';
  static const publishError = 'Publication impossible. Réessaie.';
  static const publishNeedMedia = 'Ajoute une photo ou une vidéo.';
  static const publishNotEligibleTitle = 'Profil non validé';
  static const publishNotEligibleBody =
      'Complète et valide ton profil (catalogue) pour publier des Reels.';
  static const deleteConfirmTitle = 'Supprimer ce Reel ?';
  static const deleteConfirmBody = 'Cette action est définitive.';
  static const deleteAction = 'Supprimer';
  static const deleteSuccess = 'Reel supprimé.';
  static const deleteError = 'Suppression impossible.';
  static const statusDraft = 'Brouillon';
  static const statusPublished = 'Publié';
  static const statusHidden = 'Masqué';
  static String likesCount(int n) => n <= 1 ? '$n j’aime' : '$n j’aimes';
  static String viewsCount(int n) => n <= 1 ? '$n vue' : '$n vues';

  static const profileReservationsTitle = 'Mes réservations';
  static const profileReservationsHint =
      'À venir, en attente et passées';
}

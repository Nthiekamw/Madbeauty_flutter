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
  static const likeNeedClient =
      'Active ton espace cliente pour aimer un Reel.';
  static const captionFallback = '';

  static const favoriteTooltip = 'Enregistrer';
  static const unfavoriteTooltip = 'Retirer des favoris';
  static const favoriteLoginRequired =
      'Connecte-toi pour enregistrer un Reel.';
  static const favoriteError = 'Impossible de mettre à jour le favori.';
  static const favoriteNeedClient =
      'Active ton espace cliente pour enregistrer un Reel.';
  static const favoriteAdded = 'Reel enregistré.';
  static const favoriteRemoved = 'Reel retiré des favoris.';

  static const shareTooltip = 'Partager';
  static const shareError = 'Partage impossible. Réessaie.';
  static String shareSubject(String salon) => 'Reel · $salon — MadBeauty';
  static String shareMessage(String salon, String? caption) {
    final cap = caption?.trim();
    if (cap != null && cap.isNotEmpty) {
      return 'Regarde ce Reel de $salon sur MadBeauty : $cap';
    }
    return 'Regarde ce Reel de $salon sur MadBeauty';
  }

  static const savedTitle = 'Reels enregistrés';
  static const savedHint = 'Tes posts favoris du fil Reel';
  static const savedEmptyTitle = 'Aucun Reel enregistré';
  static const savedEmptyBody =
      'Appuie sur le marque-page dans le fil Reel pour les retrouver ici.';
  static const savedLoadError = 'Impossible de charger tes Reels favoris.';
  static const savedOpenReel = 'Voir le Reel';

  static const commentTooltip = 'Commentaires';
  static const commentsSheetTitle = 'Commentaires';
  static const commentsEmptyTitle = 'Aucun commentaire';
  static const commentsEmptyBody =
      'Sois la première à commenter ce Reel.';
  static const commentsLoadError = 'Impossible de charger les commentaires.';
  static const commentHint = 'Ajouter un commentaire…';
  static const commentSend = 'Publier';
  static const commentLoginRequired =
      'Connecte-toi pour commenter un Reel.';
  static const commentError = 'Impossible d’envoyer le commentaire.';
  static const commentNeedClient =
      'Active ton espace cliente pour commenter un Reel.';
  static const commentRateLimit =
      'Trop de commentaires aujourd’hui. Réessaie demain.';
  static const commentInvalid =
      'Écris un commentaire entre 1 et 500 caractères.';
  static const commentDelete = 'Supprimer';
  static const commentDeleteError = 'Suppression impossible.';
  static String commentsCount(int n) =>
      n <= 1 ? '$n commentaire' : '$n commentaires';

  static const menuTitle = 'Mes Reels';
  static const menuHint = 'Publie des photos (galerie) ou une vidéo pour tes clientes';
  static const manageTitle = 'Mes Reels';
  static const manageEmptyTitle = 'Aucun Reel publié';
  static const manageEmptyBody =
      'Ajoute une ou plusieurs photos (ou une vidéo) pour apparaître dans le fil Reel.';
  static const manageLoadError = 'Impossible de charger tes Reels.';
  static const publishCta = 'Nouveau Reel';
  static const publishTitle = 'Publier un Reel';
  static const publishCaptionLabel = 'Légende (optionnel)';
  static const publishCaptionHint = 'Ex. : Soft glam pour un mariage…';
  static const publishPickMedia = 'Choisir photo ou vidéo';
  static const publishPickPhotos = 'Plusieurs photos';
  static const publishPickVideo = 'Une vidéo';
  static String publishPhotosCount(int n) =>
      n <= 1 ? '$n photo sélectionnée' : '$n photos sélectionnées';
  static const publishSubmit = 'Publier';
  static const publishSuccess = 'Reel publié.';
  static const publishError = 'Publication impossible. Réessaie.';
  static const publishNeedMedia = 'Ajoute une photo ou une vidéo.';
  static String publishMediaLimit(int max) =>
      'Maximum $max photos par Reel.';
  static const publishSingleVideoOnly =
      'Un seul Reel vidéo à la fois (pas de multi-vidéo).';
  static const publishNoMixVideoPhotos =
      'Un Reel est soit une galerie de photos, soit une seule vidéo.';
  static const publishNotEligibleTitle = 'Profil non validé';
  static const publishNotEligibleBody =
      'Complète et valide ton profil (catalogue) pour publier des Reels.';
  static String mediaIndexLabel(int current, int total) => '$current/$total';
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

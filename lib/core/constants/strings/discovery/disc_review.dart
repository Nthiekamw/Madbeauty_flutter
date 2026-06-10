/// Avis client après prestation terminée.
abstract final class DiscReview {
  DiscReview._();

  static const rateTitle = 'Noter la prestation';
  static const rateSubtitle =
      'Ta note aide les autres clientes à choisir leur prestataire.';
  static const commentHint = 'Commentaire (optionnel)';
  static const photosTitle = 'Photos (optionnel)';
  static const photosHint = 'Jusqu’à 3 photos de ta prestation';
  static const photosAdd = 'Ajouter une photo';
  static const photosMax = 'Maximum 3 photos par avis.';
  static const submit = 'Publier mon avis';
  static const alreadyRated = 'Avis publié';
  static const rateCta = 'Noter';
  static const success = 'Merci pour ton avis !';
  static const errorGeneric =
      'Impossible d’enregistrer l’avis. Réessaie dans un instant.';
  static const errorNotCompleted =
      'Tu pourras noter une fois la prestation terminée.';
  static const errorAlreadyExists = 'Tu as déjà noté cette réservation.';
  static const errorEditExpired =
      'Tu ne peux plus modifier cet avis (délai d’un mois dépassé).';

  static const myReviewsTitle = 'Mes avis';
  static const myReviewsSubtitle =
      'Consulte et modifie tes avis publiés.';
  static const emptyTitle = 'Aucun avis pour l’instant';
  static const emptyBody =
      'Après une prestation terminée, laisse un avis depuis Historique ou Mes réservations.';
  static const editTitle = 'Modifier mon avis';
  static const viewTitle = 'Mon avis';
  static const editSubmit = 'Enregistrer les modifications';
  static const editSuccess = 'Avis mis à jour.';
  static const editDeadlineHint =
      'Modifiable pendant 30 jours après publication.';
  static const editExpiredLabel = 'Modification impossible (délai dépassé)';
  static const prestataireViewOnlyHint =
      'Lecture seule — seule la cliente peut modifier son avis.';
  static const receivedReviewsTitle = 'Avis reçus';
  static const receivedReviewsSubtitle =
      'Avis publiés sur ton activité (consultation uniquement).';
  static const editBlockedOnOwnBusiness =
      'Tu ne peux pas modifier un avis publié sur ton activité.';

  static String starsSelected(int note) => '$note / 5';
  static String daysLeftToEdit(int days) =>
      days <= 0 ? 'Dernier jour pour modifier' : 'Encore $days j pour modifier';
}

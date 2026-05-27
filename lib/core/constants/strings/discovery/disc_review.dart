/// Avis client après prestation terminée.
abstract final class DiscReview {
  DiscReview._();

  static const rateTitle = 'Noter la prestation';
  static const rateSubtitle =
      'Ta note aide les autres clientes à choisir leur prestataire.';
  static const commentHint = 'Commentaire (optionnel)';
  static const submit = 'Publier mon avis';
  static const alreadyRated = 'Avis publié';
  static const rateCta = 'Noter';
  static const success = 'Merci pour ton avis !';
  static const errorGeneric =
      'Impossible d’enregistrer l’avis. Réessaie dans un instant.';
  static const errorNotCompleted =
      'Tu pourras noter une fois la prestation terminée.';
  static const errorAlreadyExists = 'Tu as déjà noté cette réservation.';

  static String starsSelected(int note) => '$note / 5';
}

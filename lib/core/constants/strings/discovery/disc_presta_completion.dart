/// Parcours guidé de complétion du profil prestataire.
abstract final class DiscPrestaCompletion {
  DiscPrestaCompletion._();

  static const title = 'Complète ton profil';
  static const introHeadline = 'Bienvenue dans ton espace pro';
  static const introBody =
      'Quelques étapes pour présenter ton salon aux clientes : '
      'identité, adresse, spécialités, services et photos de tes réalisations.';
  static const introLater = 'Explorer le tableau de bord';
  static const introStart = 'Commencer';
  static const stepOf = 'Étape';
  static const stepIntro = 'Bienvenue';
  static const stepBasics = 'Salon & vitrine';
  static const stepServices = 'Services & tarifs';
  static const stepGallery = 'Réalisations';
  static const stepDone = 'C’est prêt';
  static const doneHeadline = 'Profil prêt pour le catalogue';
  static const doneBody =
      'Tu peux ajuster ta vitrine à tout moment depuis l’onglet Profil. '
      'Pense à tenir ton agenda à jour.';
  static const doneCta = 'Accéder au tableau de bord';
  static const checklistTitle = 'À compléter';
  static const checklistBasics =
      'Salon, nom affiché, lieu de travail, adresse, code postal, description & photo';
  static const checklistServices =
      'Au moins un service avec catégorie';
  static const checklistGallery = 'Photos de réalisations';
  static const galleryHint =
      'Ajoute 1 à 10 photos de tes meilleures prestations (JPEG, PNG ou WebP).';
  static const galleryPick = 'Ajouter des photos';
  static const galleryEmpty = 'Aucune photo pour l’instant.';
  static const galleryUploading = 'Envoi des photos…';
  static const reqGallery = 'Ajoute au moins une photo de réalisation.';
  static const reqAddress = 'Saisis l’adresse de ton salon.';
  static const salonAddress = 'Adresse du salon';
  static const salonAddressHint = 'Numéro et rue — visible sur ta fiche';
}

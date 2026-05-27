/// Parcours guidé de complétion du profil prestataire.
abstract final class DiscPrestaCompletion {
  DiscPrestaCompletion._();

  static const title = 'Complète ton profil';
  static const introHeadline = 'Bienvenue dans ton espace pro';
  static const introBody =
      'Quelques étapes pour présenter ton salon aux clientes : '
      'identité, adresse, spécialités, services, puis des photos si tu le souhaites.';
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
  static const doneTip1 =
      'Affiner photo, bio et services depuis l’onglet Profil prestataire.';
  static const doneTip2 =
      'Réponds vite aux demandes : la réactivité rassure les clientes.';
  static const doneCta = 'Accéder au tableau de bord';
  static const railTitle = 'Vue d’ensemble';
  /// Sous-section intro (parcours avant la checklist dynamique).
  static const checklistLead =
      'Voici les étapes pour apparaître au mieux dans le catalogue.';
  static const checklistTitle = 'À compléter';
  static const introTimeHint =
      'En quelques minutes, ta vitrine est prête.';
  static const checklistBasics =
      'Salon, nom affiché, lieu de travail, adresse, code postal, description & photo';
  static const checklistServices =
      'Au moins un service avec catégorie';
  static const checklistGallery = 'Photos de réalisations';
  static const galleryHint =
      'Ajoute jusqu’à 10 photos de tes meilleures prestations '
      '(JPEG, PNG ou WebP) pour valoriser ton savoir-faire et rassurer les clientes.';
  static const gallerySkipHint =
      'Une belle galerie améliore ta crédibilité et peut augmenter les réservations.';
  static const galleryPick = 'Ajouter des photos';
  static const galleryEmpty = 'Aucune photo pour l’instant.';
  static const galleryUploading = 'Envoi des photos…';
  static const reqGallery = 'Ajoute au moins une photo de réalisation.';
  static const reqAddress = 'Saisis l’adresse de ton salon.';
  static const salonAddress = 'Adresse du salon';
  static const salonAddressHint = 'Numéro et rue — visible sur ta fiche';
}

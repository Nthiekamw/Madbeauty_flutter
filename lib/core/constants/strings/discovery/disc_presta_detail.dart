/// Fiche publique prestataire (listing → détail).
abstract final class DiscPrestaDetail {
  DiscPrestaDetail._();

  static const screenTitle = 'Prestataire';
  static const missing =
      'Ce profil n’existe pas ou n’est plus disponible.';
  static const loadErr =
      'Impossible de charger cette fiche. Réessaie.';
  static const badgeVerified = 'Profil vérifié';
  static const badgeNewTalent = 'Nouvelle pépite';
  static const salonNameTitle = 'Salon / activité';
  static const descriptionTitle = 'Présentation';
  static const bioTitle = 'À propos';
  static const experienceTitle = 'Expérience';
  static const experienceYearsLabel = 'Durée d’activité';
  static const workLocationTitle = 'Lieu de prestation';
  static const horairesTitle = 'Horaires d’ouverture';
  static const horairesEmptyTitle = 'Horaires non renseignés';
  static const horairesEmptyBody =
      'Les créneaux habituels apparaîtront ici. Tu peux quand même proposer une réservation.';
  static const comfortTitle = 'Confort client';
  static const conditionsTitle = 'Conditions de service';
  static const specialtiesTitle = 'Spécialités';
  static const galleryTitle = 'Réalisations';
  static const svcTitle = 'Services';
  static const reviewsTitle = 'Avis clients';
  static const actionBook = 'Réserver un service';
  static const actionBookSvc = 'Réserver';
  static const ownProfileBookHint =
      'C’est ton profil professionnel : tu peux le consulter, mais pas réserver tes propres services.';
  static const share = 'Partager';
  static const shareTooltip = 'Partager cette fiche';
  static String shareMessage(String name) =>
      'Découvre $name sur MadBeauty — réserve un soin en quelques clics.';
  static const contact = 'Contacter';
  static const contactSectionTitle = 'Messagerie';
  static const contactBookTitle = 'Réserve pour échanger';
  static const contactBookBody =
      'Après ta réservation, le prestataire accepte ou refuse la demande. '
      'Tu pourras ensuite lui écrire ici.';
  static const contactPendingTitle = 'Demande en attente';
  static const contactPendingBody =
      'Ton prestataire n’a pas encore répondu. Le chat s’ouvrira '
      'dès qu’il aura confirmé ta réservation.';
  static const contactViewReservations = 'Voir mes réservations';
  static const contactReadyBody =
      'Ta réservation est confirmée. Organise ton rendez-vous par message.';
  static const contactOpenChat = 'Ouvrir la conversation';
  static String reviewDate(DateTime date) {
    final d = date;
    final months = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
  static const bookingSoon =
      'La réservation arrive bientôt pour ce prestataire.';
  static const trustId = 'Identité professionnelle vérifiée';
  static const trustPrices = 'Services et tarifs visibles';
  static const trustBook = 'Réservation simple';
  static const trustFastResponse = 'Répond en général sous 2 h';
  static const noSvcsTitle =
      'Aucun service publié pour le moment';
  static const noSvcsBody =
      'Ce prestataire complète encore son catalogue. Reviens bientôt pour réserver.';
  static const noPhotosTitle =
      'Aucune réalisation publiée pour le moment';
  static const noPhotosBody =
      'Les photos de réalisations apparaîtront ici dès que le prestataire les ajoutera.';
  static const noReviewsTitle = 'Aucun avis client pour le moment';
  static const noReviewsBody =
      'Les avis apparaîtront ici après les premières réservations.';
}

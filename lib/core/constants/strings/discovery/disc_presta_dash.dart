/// Tableau de bord prestataire synthétique.
abstract final class DiscPrestaDash {
  DiscPrestaDash._();

  static const welcome =
      'Ton profil est prêt à être visible par les clients.';
  static const profileMissing =
      'Complète ton profil professionnel pour commencer.';
  static const editProfile = 'Modifier mon profil';
  static const editHoraires = 'Mes horaires';
  static const svcCount = 'Services';
  static const specialties = 'Spécialités';
  static const city = 'Ville';

  static const pendingTitle = 'Demandes en attente';
  static const pendingEmpty =
      'Aucune demande en attente. Les nouvelles réservations apparaîtront ici.';
  static const todayTitle = 'Aujourd\'hui';
  static const todayEmpty =
      'Aucun rendez-vous confirmé pour aujourd\'hui.';
  static const weekTitle = 'Cette semaine';
  static const weekEmpty =
      'Aucun autre rendez-vous confirmé cette semaine.';
  static const accept = 'Accepter';
  static const reject = 'Refuser';
  static const loadErr =
      'Impossible de charger les réservations. Réessaie.';
  static const actionOk = 'Réservation mise à jour.';
  static const actionErr =
      'Action impossible. Réessaie dans un instant.';
  static const unknownClient = 'Client';
  static const unknownService = 'Service';
  static const rejectConfirmTitle = 'Refuser cette demande ?';
  static const rejectConfirmBody =
      'Le client sera notifié que la réservation est annulée.';
}

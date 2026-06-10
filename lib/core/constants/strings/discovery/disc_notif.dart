/// Notifications in-app / affichage boîte de réception locale.
abstract final class DiscNotif {
  DiscNotif._();

  static const sheetTitle = 'Notifications';
  static const clearAll = 'Tout effacer';
  static const markAllRead = 'Tout marquer comme lu';
  static const readLabel = 'Lu';
  static const unreadLabel = 'Non lu';
  static const emptyTitle = 'Pas encore de notification';
  static const emptyBody =
      'Quand vous recevez des alertes (réservations, confirmations…), '
      'elles apparaîtront ici. Activez aussi les notifications du téléphone pour ne rien manquer.';
  static const syncErr =
      'Impossible de charger l’historique des alertes. Réessaie.';

  static const bookingPendingTitle = 'Nouvelle demande de réservation';
  static const bookingConfirmedTitle = 'Réservation confirmée';
  static const bookingCancelledTitle = 'Réservation annulée';
  static const bookingDoneTitle = 'Prestation terminée';

  static const clientPendingTitle = 'Demande envoyée';
  static const clientConfirmedTitle = 'Réservation confirmée';
  static const clientCancelledTitle = 'Réservation annulée';
  static const clientDoneTitle = 'Prestation terminée';

  static String bookingBody({
    required String clientOrSalon,
    required String service,
  }) =>
      '$clientOrSalon · $service';

  static const prestataireLikeTitle = 'Nouveau like sur ton profil';
  static String prestataireLikeBody(String clientName) =>
      '$clientName a aimé ton profil MadBeauty.';

  static const verificationApprovedTitle = 'Profil vérifié';
  static const verificationApprovedBody =
      'Ton profil prestataire est approuvé sur MadBeauty.';

  static const verificationRevokedTitle = 'Vérification à corriger';
  static String verificationRevokedBody(String reason) =>
      reason.trim().isEmpty
          ? 'L’équipe a retiré ta vérification. Consulte ton profil.'
          : 'Corrections demandées : $reason';
}

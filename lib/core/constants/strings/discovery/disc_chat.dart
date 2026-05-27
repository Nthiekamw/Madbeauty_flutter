/// Messagerie client / prestataire (réservation).
abstract final class DiscChat {
  DiscChat._();

  static const inboxTitle = 'Messages';
  static const emptyTitle = 'Aucune conversation';
  static const emptyBody =
      'Après une réservation, échange ici avec ton prestataire ou ta cliente.';
  static const emptyBodyClient =
      'Réserve un prestataire puis utilise le bouton Message sur ta réservation pour démarrer un échange.';
  static const emptyBodyPresta =
      'Quand une cliente réserve chez toi, la conversation apparaîtra ici automatiquement.';
  static const emptyActionBrowse = 'Découvrir les prestataires';
  static const emptyActionReservations = 'Voir mes réservations';
  static const emptyActionAgenda = 'Voir mon agenda';
  static const readLabel = 'Lu';
  static const unreadLabel = 'Non lu';
  static String unreadCountLabel(int count) =>
      count == 1 ? '1 non lu' : '$count non lus';
  static const profileShortcut = 'Messages';
  static const profileSectionTitle = 'Messages';
  static const profileShortcutHint = 'Conversations liées à tes réservations';
  static const inputHint = 'Message';
  static const send = 'Envoyer';
  static const loadError = 'Impossible de charger les messages.';
  static const sendError = 'Envoi impossible. Réessaie.';
  static const loginRequired = 'Connecte-toi pour accéder à tes messages.';
  static const reservationPrefix = 'Réservation';
  static const you = 'Vous';
  static const openChat = 'Message';
  static const today = 'Aujourd\'hui';
  static const yesterday = 'Hier';
}

/// Messagerie client / prestataire (réservation).
abstract final class DiscChat {
  DiscChat._();

  static const inboxTitle = 'Chat';
  static const emptyTitle = 'Aucune conversation';
  static const emptyBody =
      'Après une réservation, échange ici avec ton prestataire ou ta cliente.';
  static const emptyBodyClient =
      'Réserve un prestataire. Une fois ta demande acceptée, le chat s’ouvre depuis tes réservations.';
  static const emptyBodyPresta =
      'Quand une cliente réserve chez toi, la conversation apparaîtra ici automatiquement.';
  static const readLabel = 'Lu';
  static const unreadLabel = 'Non lu';
  static String unreadCountLabel(int count) =>
      count == 1 ? '1 non lu' : '$count non lus';
  static const profileShortcut = 'Chat';
  static const profileSectionTitle = 'Chat';
  static const profileShortcutHint = 'Conversations liées à tes réservations';
  static const inputHint = 'Message';
  static const send = 'Envoyer';
  static const loadError = 'Impossible de charger les messages.';
  static const sendError = 'Envoi impossible. Réessaie.';
  static const phoneBlocked =
      'Les numéros de téléphone ne sont pas autorisés dans le chat.';

  static const moderationDialogTitle = 'Message non autorisé';
  static const moderationDialogOk = 'Compris';
  static const moderationMultipleBlocked =
      'Pour votre sécurité, ce message ne peut pas être envoyé '
      '(téléphone, e-mail, lien ou coordonnées bancaires). '
      'Échange uniquement via MadBeauty.';
  static const moderationPhoneBlocked =
      'Pour votre sécurité, les numéros de téléphone ne peuvent pas être '
      'envoyés. Utilise la messagerie pour organiser ton rendez-vous.';
  static const moderationEmailBlocked =
      'Les adresses e-mail ne sont pas autorisées dans le chat.';
  static const moderationLinkBlocked =
      'Les liens internet ne sont pas autorisés. Reste sur la messagerie MadBeauty.';
  static const moderationBankBlocked =
      'Les coordonnées bancaires (RIB, IBAN…) ne sont pas autorisées.';
  static const moderationExternalContactBlocked =
      'Évite de partager WhatsApp, Instagram ou d’autres contacts '
      'en dehors de l’application.';
  static const quickRepliesLabel = 'Réponses rapides';
  static const moderationSafetyHint =
      'Pour ta sécurité, ne partage pas ton numéro, ton e-mail ni de liens '
      'dans le chat.';
  static const loginRequired = 'Connecte-toi pour accéder à tes messages.';
  static const reservationPrefix = 'Réservation';
  static const you = 'Vous';
  static const openChat = 'Chat';
  /// Message quand « Contacter » est utilisé sans aucune réservation avec ce pro.
  static const contactRequiresBooking =
      'Réserve d\'abord chez ce prestataire pour pouvoir lui écrire.';
  static const contactAwaitingPresta =
      'Le prestataire doit accepter ou refuser ta demande avant d’ouvrir le chat.';
  static const contactNotConfirmed =
      'Le chat est disponible une fois ta réservation confirmée.';
  static const today = 'Aujourd\'hui';
  static const yesterday = 'Hier';
}

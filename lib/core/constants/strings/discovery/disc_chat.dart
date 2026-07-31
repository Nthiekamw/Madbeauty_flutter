/// Messagerie client / prestataire (réservation).
abstract final class DiscChat {
  DiscChat._();

  static const inboxTitle = 'Chat';
  static const emptyTitle = 'Aucune conversation';
  static const emptyBody =
      'Après une réservation, échange ici avec ton prestataire ou ta cliente.';
  static const emptyBodyClient =
      'Demande un devis depuis une fiche, ou réserve : le chat s’ouvre aussi après acceptation.';
  static const emptyBodyPresta =
      'Quand une cliente te contacte pour un devis ou réserve chez toi, la conversation apparaît ici.';
  static const inquiryBanner =
      'Conversation devis / conseil — sans réservation liée.';
  static const inquiryBookCta = 'Réserver';
  static const readLabel = 'Lu';
  static const sentLabel = 'Envoyé';
  static const unreadLabel = 'Non lu';
  static const imageMessagePreview = 'Photo';
  static const resultMediaPreview = 'Rendu';
  static const resultLabelBefore = 'Avant';
  static const resultLabelAfter = 'Après';
  static const resultLabelResult = 'Rendu';
  static const sendResultMedia = 'Envoyer un rendu';
  static const sendResultMediaTitle = 'Envoyer un rendu';
  static const sendResultMediaBody =
      'Choisis le type de photo à envoyer à ta cliente.';
  static const sendResultMediaSuccess = 'Rendu envoyé dans le chat.';
  static const sendResultMediaError =
      'Impossible d’envoyer le rendu. Réessaie.';
  static const attachImageTooltip = 'Ajouter une photo';
  static const imagePickError = 'Impossible d’ajouter cette photo. Réessaie.';
  static String unreadCountLabel(int count) =>
      count == 1 ? '1 non lu' : '$count non lus';
  static const profileShortcut = 'Chat';
  static const profileSectionTitle = 'Chat';
  static const profileShortcutHint = 'Conversations liées à tes réservations';
  /// Sous-titre court de l'en-tête workspace (onglet Messages).
  static const inboxHeaderSubtitleClient = 'Tes conversations';
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
      '(coordonnées, contenu inapproprié ou langage offensant). '
      'Reste courtois et utilise la messagerie MadBeauty.';
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
  static const moderationAddressBlocked =
      'Les adresses postales ne peuvent pas être partagées dans le chat. '
      'Organise le rendez-vous via MadBeauty.';
  static const moderationSolicitationBlocked =
      'Demander un numéro, un e-mail ou une adresse personnelle '
      'n’est pas autorisé. Utilise la messagerie MadBeauty.';
  static const moderationInsultBlocked =
      'Les insultes et le langage agressif ne sont pas autorisés. '
      'Merci de rester respectueux.';
  static const moderationSexualBlocked =
      'Le contenu sexuel explicite n’est pas autorisé dans le chat. '
      'Ce canal sert uniquement à organiser ta réservation.';
  static const quickRepliesLabel = 'Réponses rapides';
  static const moderationSafetyHint =
      'Pour ta sécurité, ne partage pas tes coordonnées ni de contenu '
      'inapproprié. Reste courtois.';
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

  static const deleteCancel = 'Annuler';
  static const deleteConfirm = 'Supprimer';
  static const deleteChatAction = 'Supprimer la conversation';
  static const deleteChatTitle = 'Supprimer la conversation ?';
  static const deleteChatBody =
      'Tous les messages de cette conversation seront définitivement supprimés pour toi et ton interlocuteur. Cette action est irréversible.';
  static const deleteChatSuccess = 'Conversation supprimée.';
  static const deleteChatError =
      'Impossible de supprimer la conversation. Réessaie.';

  static const deleteMessageAction = 'Supprimer le message';
  static const deleteMessageTitle = 'Supprimer ce message ?';
  static const deleteMessageBody =
      'Ce message sera définitivement supprimé. Cette action est irréversible.';
  static const deleteMessageSuccess = 'Message supprimé.';
  static const deleteMessageError =
      'Impossible de supprimer ce message. Réessaie.';
  static const deleteMessageOwnOnly =
      'Tu ne peux supprimer que tes propres messages.';

  static const presenceOnline = 'En ligne';
  static const presenceUnknown = 'Hors ligne';
  static const presenceJustNow = 'Vu à l\'instant';
  static String presenceMinutesAgo(int minutes) =>
      'Vu il y a $minutes min';
  static String presenceHoursAgo(int hours) => 'Vu il y a $hours h';
  static String presenceYesterdayAt(String time) => 'Vu hier à $time';
  static String presenceOnDate(String formatted) => 'Vu le $formatted';

  static String resultLabelTitle(String? label) => switch (label) {
        'before' => resultLabelBefore,
        'after' => resultLabelAfter,
        'result' => resultLabelResult,
        _ => resultLabelResult,
      };
}

/// Chat support utilisateur ↔ admin.
abstract final class DiscSupport {
  DiscSupport._();

  static const screenTitle = 'Support utilisateur';
  static const screenTitleAdmin = 'Support utilisateur';
  static const subtitle = 'Échange avec l’équipe MadBeauty';
  static const emptyTitle = 'Aucun message pour l’instant';
  static const emptyBody =
      'Écris ton message ci-dessous : l’équipe te répondra dès que possible.';
  static const emptyBodyAdmin =
      'Réponds à l’utilisateur pour l’aider avec son compte ou l’application.';
  static const sendErr =
      'Impossible d’envoyer le message. Réessaie plus tard.';
  static const loadErr =
      'Impossible de charger la conversation. Réessaie plus tard.';
  static const loginRequired =
      'Connecte-toi pour contacter le support.';
  static const openChat = 'Discussion ouverte';

  static const adminHubTitle = 'Support utilisateurs';
  static const adminHubSubtitle =
      'Conversations avec les clientes et prestataires.';
  static const adminEmptyTitle = 'Aucune conversation';
  static const adminEmptyBody =
      'Les utilisateurs peuvent te contacter depuis leur profil.';
  static const adminUnreadBadge = 'Non lu';
  static const adminOpenChat = 'Ouvrir la conversation';
  static const adminNoPreview = 'Pas encore de message';
}

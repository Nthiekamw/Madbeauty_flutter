/// Réponses rapides pour le chat (prestataire).
class ChatMessageTemplate {
  const ChatMessageTemplate(this.label, this.text);

  final String label;
  final String text;
}

abstract final class ChatMessageTemplates {
  ChatMessageTemplates._();

  static const prestataire = [
    ChatMessageTemplate(
      'Confirmation',
      'Bonjour, ta réservation est confirmée. À très bientôt !',
    ),
    ChatMessageTemplate(
      'Adresse',
      'Je te donne l’adresse du rendez-vous dans la messagerie MadBeauty.',
    ),
    ChatMessageTemplate(
      'Retard',
      'Je suis légèrement en retard, merci de ta patience.',
    ),
    ChatMessageTemplate(
      'Préparation',
      'Pense à arriver avec les cheveux propres et détachés, merci.',
    ),
  ];

  static const client = [
    ChatMessageTemplate(
      'Merci',
      'Merci pour la confirmation, à bientôt !',
    ),
    ChatMessageTemplate(
      'Question',
      'Bonjour, j’ai une question concernant mon rendez-vous.',
    ),
  ];
}

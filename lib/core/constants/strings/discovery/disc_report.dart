/// Signalement de contenu.
abstract final class DiscReport {
  DiscReport._();

  static const action = 'Signaler';
  static const sheetTitle = 'Signaler un contenu';
  static const sheetBody =
      'Décris le problème. Notre équipe examinera le signalement.';
  static const reasonLabel = 'Motif';
  static const detailsLabel = 'Détails (optionnel)';
  static const submit = 'Envoyer le signalement';
  static const ok = 'Signalement envoyé. Merci.';
  static const err = 'Impossible d’envoyer le signalement. Réessaie.';
  static const reasonSpam = 'Spam ou publicité';
  static const reasonHarassment = 'Harcèlement ou insultes';
  static const reasonScam = 'Arnaque ou fraude';
  static const reasonOther = 'Autre';
}

/// Liste d'attente créneaux (client).
abstract final class DiscWaitlist {
  DiscWaitlist._();

  static const title = 'Être alerté(e)';
  static const body =
      'Aucun créneau ce jour-là. Inscris-toi pour être prévenu(e) si un créneau se libère.';
  static const cta = 'M’alerter pour ce jour';
  static const ctaActive = 'Alerte activée pour ce jour';
  static const ok =
      'Tu seras alerté(e) par notification si un créneau se libère.';
  static const pushTitle = 'Créneau disponible';
  static const removed = 'Alerte retirée.';
  static const err = 'Impossible d’enregistrer l’alerte. Réessaie.';
}

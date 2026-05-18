/// Horaires / disponibilités prestataire.
abstract final class DiscPrestaHoraires {
  DiscPrestaHoraires._();

  static const title = 'Mes horaires';
  static const intro =
      'Définis tes plages de travail pour chaque jour. Les clients pourront réserver des créneaux de 30 minutes dans ces plages.';
  static const save = 'Enregistrer';
  static const saveOk = 'Horaires enregistrés.';
  static const saveErr = 'Impossible d’enregistrer. Réessaie.';
  static const loadErr = 'Impossible de charger tes horaires.';
  static const dayOff = 'Fermé';
  static const heureDebut = 'Début';
  static const heureFin = 'Fin';
  static const invalidPlage = 'L’heure de fin doit être après l’heure de début.';

  static const jours = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  /// Ordre d’affichage lun → dim (indices `jour_semaine` PG).
  static const joursSemainePg = [1, 2, 3, 4, 5, 6, 0];
}

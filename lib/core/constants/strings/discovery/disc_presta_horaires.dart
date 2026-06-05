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
  static const capacite = 'Capacité simultanée';
  static const invalidPlage = 'L’heure de fin doit être après l’heure de début.';

  static const congesTitle = 'Congés & fermetures';
  static const congesIntro =
      'Bloque une ou plusieurs journées : aucun créneau ne sera proposé aux clientes sur ces dates.';
  static const congesAdd = 'Ajouter une période';
  static const congesEmpty = 'Aucune fermeture planifiée.';
  static const congesPickRange = 'Choisir les dates';
  static const congesAdded = 'Période de fermeture enregistrée.';
  static const congesRemoved = 'Période supprimée.';
  static const congesErr = 'Impossible de mettre à jour les congés.';
  static const congesProfileErr =
      'Profil prestataire introuvable. Enregistre ton profil puis réessaie.';
  static const congesInvalidRange = 'La date de fin doit être après le début.';
  static String congesRangeLabel(DateTime start, DateTime end) {
    final s = '${start.day.toString().padLeft(2, '0')}/'
        '${start.month.toString().padLeft(2, '0')}/${start.year}';
    final e = '${end.day.toString().padLeft(2, '0')}/'
        '${end.month.toString().padLeft(2, '0')}/${end.year}';
    return start.year == end.year &&
            start.month == end.month &&
            start.day == end.day
        ? s
        : '$s → $e';
  }

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

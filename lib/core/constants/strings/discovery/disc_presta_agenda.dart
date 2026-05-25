/// Agenda prestataire (vue semaine, actions).
abstract final class DiscPrestaAgenda {
  DiscPrestaAgenda._();

  static const pageSubtitle =
      'Calendrier hebdomadaire et gestion de tes créneaux.';
  static const weekFormat = 'Semaine';
  static const todayAction = 'Aujourd’hui';
  static const statSelectedDay = 'Ce jour';
  static const statPending = 'En attente';
  static const statWeek = 'Cette semaine';
  static String dayAppointments(int count) =>
      count <= 1 ? '$count rendez-vous' : '$count rendez-vous';
  static const dayEmptyTitle = 'Journée libre';
  static const dayEmpty = 'Aucune réservation ce jour-là.';
  static const dayEmptyBody =
      'Choisis une autre date ou attends de nouvelles demandes.';
  static const loadErr = 'Impossible de charger l’agenda. Réessaie.';
  static const rejectReasonLabel = 'Motif du refus (optionnel)';
  static const rejectReasonHint =
      'Ex. créneau indisponible, congés…';
  static const markDone = 'Marquer comme terminé';
  static const realtimeHint = 'Mise à jour automatique';
}

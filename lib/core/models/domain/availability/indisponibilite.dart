/// Période de fermeture / congé du prestataire.
class Indisponibilite {
  const Indisponibilite({
    required this.id,
    required this.dateDebut,
    required this.dateFin,
  });

  final String id;
  final DateTime dateDebut;
  final DateTime dateFin;

  bool coversDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return !dateDebut.isAfter(start) && !dateFin.isBefore(end);
  }
}

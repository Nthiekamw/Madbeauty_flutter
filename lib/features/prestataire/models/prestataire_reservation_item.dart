/// Réservation enrichie pour le tableau de bord prestataire.
class PrestataireReservationItem {
  const PrestataireReservationItem({
    required this.id,
    required this.dateHeure,
    required this.statut,
    required this.serviceName,
    required this.clientName,
    this.notesClient,
    this.notesPrestataire,
  });

  final String id;
  final DateTime dateHeure;
  final String statut;
  final String serviceName;
  final String clientName;
  final String? notesClient;
  final String? notesPrestataire;
}

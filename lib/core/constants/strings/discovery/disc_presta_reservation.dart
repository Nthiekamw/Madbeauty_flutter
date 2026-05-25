/// Détail d’une réservation côté prestataire.
abstract final class DiscPrestaReservation {
  DiscPrestaReservation._();

  static const detailTitle = 'Détail de la réservation';
  static const labelClient = 'Client';
  static const labelService = 'Service';
  static const labelDate = 'Date';
  static const labelTime = 'Heure';
  static const labelStatus = 'Statut';
  static const labelClientNote = 'Note client';
  static const labelRejectReason = 'Motif';
  static const notFoundTitle = 'Réservation introuvable';
  static const notFoundBody =
      'Cette réservation n’est plus disponible ou a été supprimée.';
}

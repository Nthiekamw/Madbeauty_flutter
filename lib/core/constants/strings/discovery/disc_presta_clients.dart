/// Onglet clients prestataire (réservations par client).
abstract final class DiscPrestaClients {
  DiscPrestaClients._();

  static const pageTitle = 'Clients';
  static const pageSubtitle =
      'Réservations passées regroupées par client.';
  static const emptyTitle = 'Aucun client';
  static const emptyBody =
      'Les rendez-vous terminés ou passés apparaîtront ici, classés par client.';
  static String clientReservationCount(int count) =>
      count <= 1 ? '$count réservation' : '$count réservations';
}

/// Notifications in-app / affichage boîte de réception locale.
abstract final class DiscNotif {
  DiscNotif._();

  static const sheetTitle = 'Notifications';
  static const clearAll = 'Tout effacer';
  static const markAllRead = 'Tout marquer comme lu';
  static const readLabel = 'Lu';
  static const unreadLabel = 'Non lu';
  static const emptyTitle = 'Pas encore de notification';
  static const emptyBody =
      'Quand vous recevez des alertes (réservations, confirmations…), '
      'elles apparaîtront ici. Activez aussi les notifications du téléphone pour ne rien manquer.';
}

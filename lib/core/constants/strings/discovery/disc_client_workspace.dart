/// Coque client (accueil, recherche, chat).
abstract final class DiscClientWorkspace {
  DiscClientWorkspace._();

  static String greeting(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Bonjour ! 👋';
    return 'Bonjour $trimmed ! 👋';
  }

  static const notificationsTooltip = 'Notifications';

  static const searchSubtitle =
      'Trouvez les meilleurs pros près de chez vous';
  static const searchHint =
      'Rechercher un service, un salon, une ville…';
  static const filterTooltip = 'Filtres et tri';

  static const promoTitle = 'Réservez votre prochain look ✨';
  static const promoBody =
      'Des professionnel·les vérifié·es, des avis authentiques et la réservation en quelques taps.';
  static const promoCta = 'Explorer';

  static const sectionAvailableToday = 'Disponibles aujourd’hui ✨';
  static const seeAll = 'Voir tout';
  static const availableBadge = 'Disponible';
  static String distanceKm(double km) => 'à ${km.toStringAsFixed(1)} km';
}

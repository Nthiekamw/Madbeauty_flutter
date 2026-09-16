/// Coque client (accueil, recherche, chat).
abstract final class DiscClientWorkspace {
  DiscClientWorkspace._();

  static String greeting(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Bonjour';
    return 'Bonjour $trimmed';
  }

  static const notificationsTooltip = 'Notifications';

  static const searchSubtitle =
      'Filtre par ville, service ou disponibilité';
  static const homeWebSubtitle =
      'Créneaux, photos de réalisations, avis — autour de toi';
  static const searchHint =
      'Un style, un salon, une ville…';
  static const filterTooltip = 'Filtres et tri';

  static const promoTitle = 'Prochain rendez-vous';
  static const promoBody =
      'Regarde les réalisations, puis bloque un créneau.';
  static const promoCta = 'Ouvrir le catalogue';

  static const sectionAvailableToday = 'Disponibles aujourd’hui';
  static const seeAll = 'Voir tout';
  static const availableBadge = 'Disponible';
  static String distanceKm(double km) => 'à ${km.toStringAsFixed(1)} km';
}

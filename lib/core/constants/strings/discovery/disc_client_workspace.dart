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
      'Parcourez les prestataires près de chez vous';
  static const homeWebSubtitle =
      'Découvrez les pros près de chez vous et réservez en quelques clics';
  static const searchHint =
      'Rechercher un service, un salon, une ville…';
  static const filterTooltip = 'Filtres et tri';

  static const promoTitle = 'Réservez votre prochain look ✨';
  static const promoBody =
      'Découvrez des pros passionnés et réservez en quelques clics.';
  static const promoCta = 'Explorer';

  static const sectionAvailableToday = 'Disponibles aujourd’hui ✨';
  static const seeAll = 'Voir tout';
  static const availableBadge = 'Disponible';
  static String distanceKm(double km) => 'à ${km.toStringAsFixed(1)} km';
}

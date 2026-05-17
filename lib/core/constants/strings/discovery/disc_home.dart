/// Accueil client.
abstract final class DiscHome {
  DiscHome._();

  static const hintSearch =
      'Rechercher un style, une ville, un pseudo…';
  static const actionSearch = 'Rechercher';
  static const taglineDiscovery =
      'Découvre des pros près de chez toi et réserve en quelques gestes.';
  static const inspireTitle = 'Inspirations';
  static const inspireSub =
      'Un tap pour ouvrir le listing avec ce thème.';

  static const nearbyTitle = 'Prestataires proches';
  static const nearbySubWithLocation =
      'Triés par distance depuis ta position (rayon 50 km).';
  static const nearbySubNoLocation =
      'Active la localisation pour voir les pros autour de toi. En attendant, tri depuis Paris.';
  static const nearbyEmptyTitle = 'Aucun prestataire proche';
  static const nearbyEmptyBody =
      'Aucun profil ne correspond encore : base vide ou personne n’a renseigné sa position. '
      'Tu peux parcourir tout le catalogue.';
  static const nearbyLoadFail =
      'Impossible de charger les prestataires. Réessaie.';

  static const topRatedTitle = 'Mieux notés';
  static const topRatedSub =
      'Triés par note moyenne (les profils sans note encore en bas de liste).';
  static const topRatedEmptyTitle = 'Pas encore de classement';
  static const topRatedEmptyBody =
      'Aucune note moyenne enregistrée pour l’instant. Ouvre le catalogue pour découvrir les salons.';
  static const ctaBrowseCatalog = 'Voir le catalogue';

  /// Distance affichée (Haversine, [km]).
  static String nearbyKm(double km) {
    if (km.isInfinite || km.isNaN) return '';
    final decimals = km < 10 ? 1 : 0;
    return '≈ ${km.toStringAsFixed(decimals)} km';
  }

  /// [displayName] : nom ou vide (« Bonjour » seul).
  static String greeting(String displayName) {
    final t = displayName.trim();
    if (t.isEmpty) return 'Bonjour';
    final first = t.split(RegExp(r'\s+')).first;
    return 'Bonjour, $first';
  }
}

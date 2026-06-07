import '../../../geo/geo_point.dart';
import '../../../geo/geo_utils.dart';
import '../user/prestataire_profile.dart';

/// Ligne catalogue : profil prestataire + affichage public (avatar, spécialités).
class PrestataireCatalogEntry {
  const PrestataireCatalogEntry({
    required this.profile,
    this.avatarUrl,
    this.userNom,
    this.userPrenom,
    required this.specialtyNames,
    this.specialtyCategoryIds = const [],
    this.reviewCount,
  });

  final PrestataireProfile profile;
  final String? avatarUrl;
  final String? userNom;
  final String? userPrenom;
  final List<String> specialtyNames;
  final List<String> specialtyCategoryIds;
  final int? reviewCount;

  /// Distance depuis [origin] ; [double.infinity] si le profil n'a pas de coordonnées.
  double distanceKmFrom(GeoPoint origin) {
    final la = profile.latitude;
    final lo = profile.longitude;
    if (la == null || lo == null) return double.infinity;
    return haversineDistanceKm(
      lat1: origin.latitude,
      lon1: origin.longitude,
      lat2: la,
      lon2: lo,
    );
  }

  String get displayName {
    final salon = profile.nomSalon?.trim();
    if (salon != null && salon.isNotEmpty) return salon;
    final parts = [
      userPrenom?.trim(),
      userNom?.trim(),
    ].where((e) => e != null && e.isNotEmpty).cast<String>().toList();
    if (parts.isEmpty) return 'Salon';
    return parts.join(' ');
  }

  /// [categorieId] `null` ou vide : pas de filtre catégorie.
  bool matchesCategoryFilter(String? categorieId) {
    if (categorieId == null || categorieId.isEmpty) return true;
    return specialtyCategoryIds.contains(categorieId);
  }

  bool matchesSearch(String rawQuery) {
    final q = rawQuery.trim().toLowerCase();
    if (q.isEmpty) return true;
    bool has(String? s) => (s ?? '').toLowerCase().contains(q);
    if (has(profile.nomSalon) ||
        has(profile.ville) ||
        has(profile.bio)) {
      return true;
    }
    for (final s in specialtyNames) {
      if (s.toLowerCase().contains(q)) return true;
    }
    return has(displayName);
  }
}


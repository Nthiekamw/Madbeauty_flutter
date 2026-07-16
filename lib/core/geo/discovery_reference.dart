import 'geo_point.dart';

/// Repère cartographique pour tri « distance » tant que la position utilisateur
/// n'est pas disponible (aligné avec [PrestataireService.getNearbyFromReference]).
const double kDiscoveryReferenceLatitude = 48.8566;
const double kDiscoveryReferenceLongitude = 2.3522;

const GeoPoint kDiscoveryReferencePoint = GeoPoint(
  latitude: kDiscoveryReferenceLatitude,
  longitude: kDiscoveryReferenceLongitude,
);

/// Rayon par défaut pour la section « prestataires proches » (km).
const double kNearbyPrestatairesRadiusKm = 50;

/// Centre géographique approximatif par marché (ISO), pour le fallback
/// « proches » / tri distance sans GPS (ex. navigateur web sans permission).
GeoPoint discoveryReferenceForMarket(String? countryIso) {
  final code = countryIso?.trim().toUpperCase();
  return switch (code) {
    'BE' => const GeoPoint(latitude: 50.8503, longitude: 4.3517), // Bruxelles
    'CA' => const GeoPoint(latitude: 45.5017, longitude: -73.5673), // Montréal
    'CH' => const GeoPoint(latitude: 46.2044, longitude: 6.1432), // Genève
    'DE' => const GeoPoint(latitude: 52.5200, longitude: 13.4050), // Berlin
    'GB' => const GeoPoint(latitude: 51.5074, longitude: -0.1278), // Londres
    'FR' || _ => kDiscoveryReferencePoint, // Paris
  };
}

import 'geo_point.dart';

/// Repère cartographique pour tri « distance » tant que la position utilisateur
/// n’est pas disponible (aligné avec [PrestataireService.getNearbyFromReference]).
const double kDiscoveryReferenceLatitude = 48.8566;
const double kDiscoveryReferenceLongitude = 2.3522;

const GeoPoint kDiscoveryReferencePoint = GeoPoint(
  latitude: kDiscoveryReferenceLatitude,
  longitude: kDiscoveryReferenceLongitude,
);

/// Rayon par défaut pour la section « prestataires proches » (km).
const double kNearbyPrestatairesRadiusKm = 50;

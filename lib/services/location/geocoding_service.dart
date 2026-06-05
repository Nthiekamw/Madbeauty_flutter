import 'package:geocoding/geocoding.dart';

import '../../core/geo/geo_point.dart';

/// Géocodage texte â†’ coordonnées (ville, adresse).
class GeocodingService {
  Future<GeoPoint?> geocodeAddress(String address) async {
    final query = address.trim();
    if (query.isEmpty) return null;

    try {
      final locations = await locationFromAddress(_normalizeQuery(query));
      if (locations.isEmpty) return null;
      final first = locations.first;
      return GeoPoint(latitude: first.latitude, longitude: first.longitude);
    } on Exception {
      return null;
    }
  }

  /// Ville ou localité à partir de coordonnées GPS.
  Future<String?> reverseGeocodeCity(GeoPoint point) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (placemarks.isEmpty) return null;
      final place = placemarks.first;
      for (final candidate in [
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
      ]) {
        final value = candidate?.trim();
        if (value != null && value.isNotEmpty) return value;
      }
      return null;
    } on Exception {
      return null;
    }
  }

  String _normalizeQuery(String query) {
    final lower = query.toLowerCase();
    if (lower.contains('france') ||
        lower.contains('réunion') ||
        lower.contains('martinique') ||
        lower.contains('guadeloupe')) {
      return query;
    }
    return '$query, France';
  }
}


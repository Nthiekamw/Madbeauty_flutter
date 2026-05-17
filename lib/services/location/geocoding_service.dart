import 'package:geocoding/geocoding.dart';

import '../../core/geo/geo_point.dart';

/// Géocodage texte → coordonnées (ville, adresse).
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

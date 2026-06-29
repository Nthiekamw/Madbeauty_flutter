import 'package:geocoding/geocoding.dart';

import '../../core/geo/geo_point.dart';
import '../../shared/utils/phone_number_utils.dart';

/// Géocodage texte → coordonnées (ville, adresse).
class GeocodingService {
  Future<GeoPoint?> geocodeAddress(
    String address, {
    String? countryIsoCode,
  }) async {
    final query = address.trim();
    if (query.isEmpty) return null;

    try {
      final locations = await locationFromAddress(
        _normalizeQuery(query, countryIsoCode: countryIsoCode),
      );
      if (locations.isEmpty) return null;
      final first = locations.first;
      return GeoPoint(latitude: first.latitude, longitude: first.longitude);
    } on Object {
      // Le plugin peut lever Error (ex. null check) sur web — ne pas bloquer l'inscription.
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
    } on Object {
      return null;
    }
  }

  String _normalizeQuery(String query, {String? countryIsoCode}) {
    final countryLabel = _countryLabelForGeocode(countryIsoCode);
    if (countryLabel == null) return query;
    final lower = query.toLowerCase();
    if (lower.contains(countryLabel.toLowerCase())) return query;
    return '$query, $countryLabel';
  }

  String? _countryLabelForGeocode(String? countryIsoCode) {
    final code = countryIsoCode?.trim().toUpperCase();
    if (code == null || code.isEmpty) return 'France';
    for (final option in PhoneNumberUtils.dialOptions) {
      if (option.isoCode == code) return option.label;
    }
    return 'France';
  }
}

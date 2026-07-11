import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/config/market_config.dart';
import '../../core/geo/geo_point.dart';
import '../../core/logic/address/postal_country_format.dart';

/// Géocodage texte → coordonnées (ville, adresse).
class GeocodingService {
  GeocodingService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const _nominatimUserAgent = 'MadBeauty/1.0 (geocoding; madbeauty-app)';

  Future<GeoPoint?> geocodeAddress(
    String address, {
    String? countryIsoCode,
  }) async {
    final query = address.trim();
    if (query.isEmpty) return null;

    final normalizedCountry = _normalizeCountryIso(countryIsoCode);
    final enrichedQuery = _enrichQueryWithCountry(query, normalizedCountry);

    final platformPoint = await _geocodeViaPlatform(
      enrichedQuery,
      countryIsoCode: normalizedCountry,
    );
    if (platformPoint != null) return platformPoint;

    return _geocodeViaNominatim(
      enrichedQuery,
      countryIsoCode: normalizedCountry,
    );
  }

  /// Code pays ISO (alpha-2) à partir de coordonnées GPS.
  Future<String?> reverseGeocodeCountryIso(GeoPoint point) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (placemarks.isEmpty) return null;
      final iso = placemarks.first.isoCountryCode?.trim().toUpperCase();
      if (iso == null || iso.isEmpty) return null;
      return MarketConfig.isSupported(iso) ? iso : null;
    } on Object {
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

  Future<GeoPoint?> _geocodeViaPlatform(
    String query, {
    String? countryIsoCode,
  }) async {
    try {
      final locations = await locationFromAddress(
        _enrichQueryWithCountry(query, countryIsoCode),
      );
      if (locations.isEmpty) return null;
      final first = locations.first;
      return GeoPoint(latitude: first.latitude, longitude: first.longitude);
    } on Object {
      // Le plugin peut lever Error (ex. null check) sur web — fallback Nominatim.
      return null;
    }
  }

  Future<GeoPoint?> _geocodeViaNominatim(
    String query, {
    String? countryIsoCode,
  }) async {
    try {
      final params = <String, String>{
        'q': query,
        'format': 'json',
        'limit': '1',
        'addressdetails': '0',
      };
      final code = countryIsoCode?.trim().toLowerCase();
      if (code != null && code.length == 2) {
        params['countrycodes'] = code;
      }

      final uri = Uri.https('nominatim.openstreetmap.org', '/search', params);
      final response = await _httpClient
          .get(
            uri,
            headers: const {
              'accept': 'application/json',
              'User-Agent': _nominatimUserAgent,
            },
          )
          .timeout(AppConfig.supabaseHttpTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List || decoded.isEmpty) return null;
      final first = decoded.first;
      if (first is! Map<String, dynamic>) return null;

      final lat = double.tryParse('${first['lat']}');
      final lon = double.tryParse('${first['lon']}');
      if (lat == null || lon == null) return null;
      return GeoPoint(latitude: lat, longitude: lon);
    } on Object {
      return null;
    }
  }

  String _enrichQueryWithCountry(String query, String? countryIsoCode) {
    final countryLabel = _countryLabelForGeocode(countryIsoCode);
    if (countryLabel == null) return query;
    final lower = query.toLowerCase();
    if (lower.contains(countryLabel.toLowerCase())) return query;
    return '$query, $countryLabel';
  }

  String? _countryLabelForGeocode(String? countryIsoCode) {
    final code = _normalizeCountryIso(countryIsoCode);
    if (code == null) return 'France';
    if (MarketConfig.isSupported(code)) {
      return MarketConfig.definitionFor(code).labelFr;
    }
    return postalCountryLabelForIso(code);
  }

  String? _normalizeCountryIso(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;
    if (value.length == 2) return value.toUpperCase();
    return postalCountryIso2(value);
  }
}

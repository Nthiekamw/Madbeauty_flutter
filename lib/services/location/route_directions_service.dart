import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../core/config/app_config.dart';
import '../../core/geo/geo_utils.dart';

/// Itinéraire routier (points + métriques) pour affichage carte.
class RouteDirections {
  const RouteDirections({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.isApproximate,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  /// `true` si ligne droite Haversine (échec / absence de route OSRM).
  final bool isApproximate;

  double get distanceKm => distanceMeters / 1000.0;

  Duration get duration =>
      Duration(seconds: durationSeconds.round().clamp(0, 86400 * 7));
}

/// Calcul d’itinéraire via OSRM public, avec repli ligne droite.
///
/// L’API publique OSRM convient au MVP ; pour un fort trafic, brancher un
/// endpoint dédié (self-host / fournisseur) via [osrmBaseUrl].
class RouteDirectionsService {
  final http.Client _client;
  final String osrmBaseUrl;
  final bool _ownsClient;

  static const _userAgent = 'MadBeauty/1.0 (com.madbeauty.madbeauty)';

  RouteDirectionsService({
    http.Client? httpClient,
    this.osrmBaseUrl = 'https://router.project-osrm.org',
  })  : _ownsClient = httpClient == null,
        _client = httpClient ?? http.Client();

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }

  Future<RouteDirections> drivingRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final routed = await _fetchOsrm(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
      );
      if (routed != null) return routed;
    } catch (_) {
      // Repli déterministe ci-dessous.
    }
    return straightLineFallback(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
    );
  }

  /// Parse JSON OSRM (testable sans réseau).
  static RouteDirections? parseOsrmResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return null;
    final routes = decoded['routes'];
    if (routes is! List || routes.isEmpty) return null;
    final route = routes.first;
    if (route is! Map) return null;

    final geometry = route['geometry'];
    if (geometry is! Map) return null;
    final coordinates = geometry['coordinates'];
    if (coordinates is! List || coordinates.isEmpty) return null;

    final points = <LatLng>[];
    for (final raw in coordinates) {
      if (raw is! List || raw.length < 2) continue;
      final lng = (raw[0] as num).toDouble();
      final lat = (raw[1] as num).toDouble();
      points.add(LatLng(lat, lng));
    }
    if (points.length < 2) return null;

    final distance = (route['distance'] as num?)?.toDouble() ?? 0;
    final duration = (route['duration'] as num?)?.toDouble() ?? 0;
    return RouteDirections(
      points: points,
      distanceMeters: distance,
      durationSeconds: duration,
      isApproximate: false,
    );
  }

  static RouteDirections straightLineFallback({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) {
    final km = haversineDistanceKm(
      lat1: originLat,
      lon1: originLng,
      lat2: destLat,
      lon2: destLng,
    );
    // ~30 km/h urbain approximatif pour l’estimation durée.
    final seconds = (km / 30.0) * 3600.0;
    return RouteDirections(
      points: [
        LatLng(originLat, originLng),
        LatLng(destLat, destLng),
      ],
      distanceMeters: km * 1000.0,
      durationSeconds: seconds,
      isApproximate: true,
    );
  }

  Future<RouteDirections?> _fetchOsrm({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final path =
        '/route/v1/driving/$originLng,$originLat;$destLng,$destLat';
    final uri = Uri.parse('$osrmBaseUrl$path').replace(
      queryParameters: const {
        'overview': 'full',
        'geometries': 'geojson',
      },
    );
    final response = await _client
        .get(uri, headers: {'User-Agent': _userAgent})
        .timeout(AppConfig.supabaseHttpTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }
    return parseOsrmResponse(response.body);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'geocoding_service.dart';
import 'geolocation_service.dart';

export 'geolocation_service.dart' show ClientLocation, GeolocationService;

final geolocationServiceProvider = Provider<GeolocationService>((ref) {
  return GeolocationService();
});

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingService();
});


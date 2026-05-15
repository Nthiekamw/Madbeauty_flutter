import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/location/geolocation_service.dart';

final geolocationServiceProvider = Provider<GeolocationService>((ref) {
  return GeolocationService();
});

final clientLocationProvider = FutureProvider.autoDispose<ClientLocation?>((
  ref,
) {
  final service = ref.watch(geolocationServiceProvider);
  return service.getCurrentLocation();
});

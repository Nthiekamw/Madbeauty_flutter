import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/location/location_providers.dart';

export '../../../services/location/location_providers.dart'
    show ClientLocation, geocodingServiceProvider, geolocationServiceProvider;

final clientLocationProvider = FutureProvider.autoDispose<ClientLocation?>((
  ref,
) {
  final service = ref.watch(geolocationServiceProvider);
  return service.getCurrentLocation();
});

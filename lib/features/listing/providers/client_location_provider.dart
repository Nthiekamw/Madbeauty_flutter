import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/location/location_providers.dart';
import '../../profile/providers/profile_preferences_provider.dart';

export '../../../services/location/location_providers.dart'
    show ClientLocation, geocodingServiceProvider, geolocationServiceProvider;

final clientLocationProvider = FutureProvider.autoDispose<ClientLocation?>((
  ref,
) async {
  final prefs = ref.watch(profilePreferencesProvider);
  if (!prefs.geolocationEnabled) return null;

  final service = ref.watch(geolocationServiceProvider);
  return service.getCurrentLocation();
});


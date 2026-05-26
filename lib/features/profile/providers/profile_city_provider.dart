import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/geo/geo_point.dart';
import '../../../services/location/location_providers.dart';
import '../../../services/supabase/profile/client_profile_providers.dart';
import '../../listing/providers/client_location_provider.dart';
import 'profile_preferences_provider.dart';

/// Libellé ville affiché sur le profil client.
final profileCityLabelProvider = FutureProvider.autoDispose<String>((ref) async {
  final clientProfile = await ref.watch(currentClientProfileProvider.future);
  final adresse = clientProfile?.adresse?.trim();
  if (adresse != null && adresse.isNotEmpty) {
    return adresse;
  }

  final prefs = ref.watch(profilePreferencesProvider);
  if (!prefs.geolocationEnabled) return '—';

  final location = await ref.watch(clientLocationProvider.future);
  if (location == null) return '—';

  final geocoding = ref.watch(geocodingServiceProvider);
  return await geocoding.reverseGeocodeCity(
        GeoPoint(latitude: location.latitude, longitude: location.longitude),
      ) ??
      '—';
});

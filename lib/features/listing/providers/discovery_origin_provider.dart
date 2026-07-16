import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/geo/discovery_reference.dart';
import '../../../core/geo/geo_point.dart';
import '../../../core/providers/market_country_provider.dart';
import 'client_location_provider.dart';

/// Origine pour tri / distance : position client si disponible, sinon centre marché.
final discoveryOriginProvider = Provider<GeoPoint>((ref) {
  final locationAsync = ref.watch(clientLocationProvider);
  return switch (locationAsync) {
    AsyncData(:final value) when value != null => GeoPoint(
      latitude: value.latitude,
      longitude: value.longitude,
    ),
    _ => discoveryReferenceForMarket(ref.watch(marketCountryProvider)),
  };
});

/// `true` si la position GPS du client est utilisée (pas le repère marché).
final discoveryUsesClientLocationProvider = Provider<bool>((ref) {
  final locationAsync = ref.watch(clientLocationProvider);
  return switch (locationAsync) {
    AsyncData(:final value) => value != null,
    _ => false,
  };
});

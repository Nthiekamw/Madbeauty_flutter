import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/geo/discovery_reference.dart';
import '../../../core/geo/geo_point.dart';
import 'client_location_provider.dart';

/// Origine pour tri / distance : position client si disponible, sinon Paris.
final discoveryOriginProvider = Provider<GeoPoint>((ref) {
  final locationAsync = ref.watch(clientLocationProvider);
  return switch (locationAsync) {
    AsyncData(:final value) when value != null => GeoPoint(
      latitude: value.latitude,
      longitude: value.longitude,
    ),
    _ => kDiscoveryReferencePoint,
  };
});

/// `true` si la position GPS du client est utilisée (pas le repère Paris).
final discoveryUsesClientLocationProvider = Provider<bool>((ref) {
  final locationAsync = ref.watch(clientLocationProvider);
  return switch (locationAsync) {
    AsyncData(:final value) => value != null,
    _ => false,
  };
});


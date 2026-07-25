import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/services/location/route_directions_service.dart';
import 'package:madbeauty/shared/utils/maps_directions_launcher.dart';

void main() {
  group('RouteDirectionsService.parseOsrmResponse', () {
    test('extrait points distance durée', () {
      const body = '''
{
  "routes": [{
    "distance": 2500.5,
    "duration": 420.2,
    "geometry": {
      "coordinates": [[2.35, 48.85], [2.36, 48.86], [2.37, 48.87]]
    }
  }]
}
''';
      final route = RouteDirectionsService.parseOsrmResponse(body);
      expect(route, isNotNull);
      expect(route!.points, hasLength(3));
      expect(route.points.first.latitude, closeTo(48.85, 0.0001));
      expect(route.points.first.longitude, closeTo(2.35, 0.0001));
      expect(route.distanceMeters, closeTo(2500.5, 0.01));
      expect(route.durationSeconds, closeTo(420.2, 0.01));
      expect(route.isApproximate, isFalse);
    });

    test('retourne null si routes vides', () {
      expect(
        RouteDirectionsService.parseOsrmResponse('{"routes":[]}'),
        isNull,
      );
    });
  });

  group('RouteDirectionsService.straightLineFallback', () {
    test('produit une ligne à 2 points', () {
      final route = RouteDirectionsService.straightLineFallback(
        originLat: 48.85,
        originLng: 2.35,
        destLat: 48.86,
        destLng: 2.36,
      );
      expect(route.points, hasLength(2));
      expect(route.isApproximate, isTrue);
      expect(route.distanceMeters, greaterThan(0));
    });
  });

  group('MapsDirectionsLauncher.buildDirectionsUri', () {
    test('construit une URL Google avec origine et destination', () {
      final uri = MapsDirectionsLauncher.buildDirectionsUri(
        destLat: 48.87,
        destLng: 2.33,
        originLat: 48.85,
        originLng: 2.35,
      );
      expect(uri.host, anyOf('www.google.com', 'maps.apple.com'));
      expect(uri.queryParameters.containsKey('destination') ||
          uri.queryParameters.containsKey('daddr'), isTrue);
    });
  });
}

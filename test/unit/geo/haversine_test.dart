import 'package:flutter_test/flutter_test.dart';

import 'package:madbeauty/core/geo/geo_utils.dart';

void main() {
  test('haversineDistanceKm : même point ≈ 0', () {
    expect(
      haversineDistanceKm(
        lat1: 48.8566,
        lon1: 2.3522,
        lat2: 48.8566,
        lon2: 2.3522,
      ),
      lessThan(0.01),
    );
  });

  test('haversineDistanceKm : Paris → Lyon cohérent (~390 km)', () {
    final km = haversineDistanceKm(
      lat1: 48.8566,
      lon1: 2.3522,
      lat2: 45.7640,
      lon2: 4.8357,
    );
    expect(km, greaterThan(350));
    expect(km, lessThan(450));
  });
}

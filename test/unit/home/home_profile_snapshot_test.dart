import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/features/home/models/home_profile_snapshot.dart';

void main() {
  group('HomeProfileSnapshot', () {
    test('toJson serialise email et displayName', () {
      const snapshot = HomeProfileSnapshot(
        email: 'user@madbeauty.app',
        displayName: 'User Name',
        isFromCache: false,
      );

      final json = snapshot.toJson();

      expect(json['email'], 'user@madbeauty.app');
      expect(json['display_name'], 'User Name');
    });

    test('fromJson deserialise avec fallback valeurs vides', () {
      final snapshot = HomeProfileSnapshot.fromJson(
        const {},
        isFromCache: true,
      );

      expect(snapshot.email, '');
      expect(snapshot.displayName, '');
      expect(snapshot.isFromCache, isTrue);
    });

    test('fromJson conserve les valeurs presentes', () {
      final snapshot = HomeProfileSnapshot.fromJson(
        const {
          'email': 'cache@madbeauty.app',
          'display_name': 'Cached User',
        },
        isFromCache: true,
      );

      expect(snapshot.email, 'cache@madbeauty.app');
      expect(snapshot.displayName, 'Cached User');
      expect(snapshot.isFromCache, isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/services/storage/local_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalCacheService.initialize();
  });

  test('setSelectedRole et selectedRole fonctionnent', () async {
    await LocalCacheService.instance.setSelectedRole('client');
    expect(LocalCacheService.instance.selectedRole, 'client');
  });

  test('clearSelectedRole supprime le role en cache', () async {
    await LocalCacheService.instance.setSelectedRole('prestataire');
    await LocalCacheService.instance.clearSelectedRole();
    expect(LocalCacheService.instance.selectedRole, isNull);
  });
}

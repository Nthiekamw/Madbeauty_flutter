import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/features/auth/logic/auth_role_cache.dart';

void main() {
  test('resolveEffectiveRole priorise admin', () {
    final role = AuthRoleCache.resolveEffectiveRole(
      serverRoleValues: ['client', 'admin'],
      cachedRole: 'client',
    );
    expect(role, 'admin');
  });

  test('hasAdminAmong détecte le rôle admin', () {
    expect(AuthRoleCache.hasAdminAmong(['client', 'admin']), isTrue);
    expect(AuthRoleCache.hasAdminAmong(['client', 'prestataire']), isFalse);
  });
}

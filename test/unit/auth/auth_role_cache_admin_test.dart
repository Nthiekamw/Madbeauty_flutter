import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:madbeauty/core/models/user_role.dart';
import 'package:madbeauty/features/auth/logic/auth_role_cache.dart';
import 'package:madbeauty/services/storage/local_cache_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalCacheService.initialize();
  });

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

  test('resolveEffectiveRole conserve le choix client avec double rôle', () async {
    await LocalCacheService.instance.setCachedServerRoles(
      ['client', 'prestataire'],
    );
    await LocalCacheService.instance.setSelectedRole('client');
    await LocalCacheService.instance.setSignupShellRole('prestataire');

    final role = AuthRoleCache.resolveEffectiveRole(
      serverRoleValues: ['client', 'prestataire'],
      cachedRole: 'client',
    );
    expect(role, 'client');
  });

  test('shouldBootstrapPrestataireProfile false si espace client choisi', () async {
    await LocalCacheService.instance.setCachedServerRoles(
      ['client', 'prestataire'],
    );
    await LocalCacheService.instance.setSelectedRole('client');

    expect(AuthRoleCache.shouldBootstrapPrestataireProfile(), isFalse);
  });

  test('shouldBootstrapPrestataireProfile true si espace prestataire actif', () async {
    await LocalCacheService.instance.setCachedServerRoles(
      ['client', 'prestataire'],
    );
    await LocalCacheService.instance.setSelectedRole('prestataire');

    expect(AuthRoleCache.shouldBootstrapPrestataireProfile(), isTrue);
  });

  test('persistServerRoles conserve le dernier espace client', () async {
    await LocalCacheService.instance.setSelectedRole('client');
    await LocalCacheService.instance.setSignupShellRole('prestataire');

    await AuthRoleCache.persistServerRoles([
      UserRole.client,
      UserRole.prestataire,
    ]);

    expect(LocalCacheService.instance.selectedRole, 'client');
  });

  test('persistServerRoles conserve le dernier espace prestataire', () async {
    await LocalCacheService.instance.setSelectedRole('prestataire');
    await LocalCacheService.instance.setSignupShellRole('client');

    await AuthRoleCache.persistServerRoles([
      UserRole.client,
      UserRole.prestataire,
    ]);

    expect(LocalCacheService.instance.selectedRole, 'prestataire');
  });
}

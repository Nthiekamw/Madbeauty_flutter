import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/features/messaging/logic/messaging_viewer_role_inference.dart';
import 'package:madbeauty/features/messaging/models/messaging_inbox_role.dart';
import 'package:madbeauty/services/storage/local_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalCacheService.initialize();
    await LocalCacheService.instance.clearSelectedRole();
  });

  test('messagingViewerRoleFromActiveShell suit selectedRole', () async {
    expect(messagingViewerRoleFromActiveShell(), isNull);

    await LocalCacheService.instance.setSelectedRole('prestataire');
    expect(
      messagingViewerRoleFromActiveShell(),
      MessagingInboxRole.prestataire,
    );

    await LocalCacheService.instance.setSelectedRole('client');
    expect(messagingViewerRoleFromActiveShell(), MessagingInboxRole.client);
  });

  test('messagingAsQueryParam priorise le rôle push puis le shell', () async {
    await LocalCacheService.instance.setSelectedRole('client');
    expect(
      messagingAsQueryParam(pushRole: 'prestataire'),
      'prestataire',
    );
    expect(messagingAsQueryParam(pushRole: null), 'client');
  });
}

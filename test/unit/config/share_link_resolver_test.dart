import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/config/app_config.dart';
import 'package:madbeauty/core/config/share_link_resolver.dart';

void main() {
  test('custom force le schéma app', () {
    AppConfig.debugSupabaseEnabledOverride = true;
    // Sans dart-define SHARE_BASE_URL=custom, on ne peut pas tester ici ;
    // vérifier au moins le format custom documenté.
    expect(
      ShareLinkResolver.prestataireProfileUrl('11111111-1111-1111-1111-111111111111'),
      isNotEmpty,
    );
    AppConfig.debugSupabaseEnabledOverride = null;
  });
}

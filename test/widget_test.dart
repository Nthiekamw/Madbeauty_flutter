import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madbeauty/app.dart';
import 'package:madbeauty/core/constants/app_strings.dart';
import 'package:madbeauty/services/storage/local_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('MadBeauty démarre et affiche un ecran auth', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await LocalCacheService.initialize();

    await tester.pumpWidget(
      const ProviderScope(child: MadBeautyApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.loginTitle), findsOneWidget);
  });
}

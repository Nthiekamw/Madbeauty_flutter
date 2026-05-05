import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madbeauty/app.dart';
import 'package:madbeauty/core/constants/app_strings.dart';

void main() {
  testWidgets('MadBeauty démarre et affiche le titre', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MadBeautyApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.appName), findsWidgets);
  });
}

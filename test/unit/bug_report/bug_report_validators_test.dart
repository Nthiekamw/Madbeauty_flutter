import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/constants/app_strings.dart';
import 'package:madbeauty/features/bug_report/logic/bug_report_validators.dart';

void main() {
  group('BugReportValidators', () {
    test('title trop court', () {
      expect(BugReportValidators.title('ab'), DiscBug.validationTitle);
      expect(BugReportValidators.title('abc'), isNull);
    });

    test('description trop courte', () {
      expect(
        BugReportValidators.description('court'),
        DiscBug.validationDescription,
      );
      expect(
        BugReportValidators.description('assez longue'),
        isNull,
      );
    });
  });
}

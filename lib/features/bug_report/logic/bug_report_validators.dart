import '../../../core/constants/app_strings.dart';

abstract final class BugReportValidators {
  BugReportValidators._();

  static String? title(String value) {
    final trimmed = value.trim();
    if (trimmed.length < 3) return DiscBug.validationTitle;
    return null;
  }

  static String? description(String value) {
    final trimmed = value.trim();
    if (trimmed.length < 10) return DiscBug.validationDescription;
    return null;
  }
}

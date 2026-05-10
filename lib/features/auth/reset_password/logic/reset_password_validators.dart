import '../../../../core/constants/app_strings.dart';

abstract final class ResetPasswordValidators {
  ResetPasswordValidators._();

  static String? password(String value) {
    if (value.isEmpty) return AppStrings.loginValidationPasswordEmpty;
    if (value.length < 8) return AppStrings.resetPasswordValidationTooShort;
    return null;
  }

  static String? confirmation(String password, String confirmation) {
    if (password != confirmation) {
      return AppStrings.resetPasswordValidationMismatch;
    }
    return null;
  }
}

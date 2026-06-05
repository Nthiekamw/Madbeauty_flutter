import '../../../../core/constants/app_strings.dart';

abstract final class ResetPasswordValidators {
  ResetPasswordValidators._();

  static String? password(String value) {
    if (value.isEmpty) return AuthStrings.loginValidationPasswordEmpty;
    if (value.length < 8) return AuthStrings.resetPasswordValidationTooShort;
    return null;
  }

  static String? confirmation(String password, String confirmation) {
    if (password != confirmation) {
      return AuthStrings.resetPasswordValidationMismatch;
    }
    return null;
  }
}


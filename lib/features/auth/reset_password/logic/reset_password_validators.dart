import '../../../../core/constants/app_strings.dart';
import '../../logic/password_policy.dart';

abstract final class ResetPasswordValidators {
  ResetPasswordValidators._();

  static String? password(String value) => PasswordPolicy.validate(value);

  static String? confirmation(String password, String confirmation) {
    if (password != confirmation) {
      return AuthStrings.resetPasswordValidationMismatch;
    }
    return null;
  }
}

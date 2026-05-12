import '../../../../core/constants/app_strings.dart';

abstract final class RegisterValidators {
  RegisterValidators._();

  static String? name(String trimmedValue) {
    if (trimmedValue.isEmpty) return AuthStrings.registerValidationNameEmpty;
    return null;
  }

  static String? email(String trimmedValue) {
    if (trimmedValue.isEmpty) return AuthStrings.registerValidationEmailEmpty;
    final emailOk = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(trimmedValue);
    if (!emailOk) return AuthStrings.registerValidationEmailInvalid;
    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) return AuthStrings.registerValidationPasswordEmpty;
    return null;
  }
}

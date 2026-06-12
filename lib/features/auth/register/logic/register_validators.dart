import '../../../../core/constants/app_strings.dart';
import '../../../../shared/utils/phone_number_utils.dart';
import '../../logic/password_policy.dart';

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

  static String? password(String value) => PasswordPolicy.validate(value);

  static String? phoneLocal(String local, {required String dialCode}) {
    final trimmed = local.trim();
    if (trimmed.isEmpty) return AuthStrings.registerValidationPhoneEmpty;
    final stored = PhoneNumberUtils.toStored(dialCode: dialCode, local: trimmed);
    if (stored.isEmpty) return AuthStrings.registerValidationPhoneInvalid;
    final digits = stored.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return AuthStrings.registerValidationPhoneInvalid;
    return null;
  }
}


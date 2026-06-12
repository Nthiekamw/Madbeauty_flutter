import '../../../core/constants/app_strings.dart';

/// Règles mot de passe alignées sur Supabase (`minimum_password_length`, `password_requirements`).
abstract final class PasswordPolicy {
  PasswordPolicy._();

  static const int minLength = 8;

  /// Retourne un message d'erreur ou `null` si le mot de passe est valide.
  static String? validate(String value) {
    if (value.isEmpty) return AuthStrings.loginValidationPasswordEmpty;
    if (value.length < minLength) {
      return AuthStrings.passwordValidationTooShort;
    }
    if (!_hasLetter(value) || !_hasDigit(value)) {
      return AuthStrings.passwordValidationRequiresLetterAndDigit;
    }
    return null;
  }

  static bool _hasLetter(String value) =>
      RegExp(r'[A-Za-zÀ-ÖØ-öø-ÿ]').hasMatch(value);

  static bool _hasDigit(String value) => RegExp(r'\d').hasMatch(value);
}

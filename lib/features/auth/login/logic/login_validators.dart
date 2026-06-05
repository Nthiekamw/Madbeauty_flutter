import '../../../../core/constants/app_strings.dart';

/// Règles de validation du formulaire de connexion (sans dépendance UI).
abstract final class LoginValidators {
  LoginValidators._();

  /// Retourne un message d'erreur affichable ou `null` si la valeur est valide.
  static String? email(String trimmedValue) {
    if (trimmedValue.isEmpty) return AuthStrings.loginValidationEmailEmpty;
    final emailOk = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(trimmedValue);
    if (!emailOk) return AuthStrings.loginValidationEmailInvalid;
    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) return AuthStrings.loginValidationPasswordEmpty;
    return null;
  }

  /// E.164 : + suivi du indicatif pays et du numéro (6 à 15 chiffres au total après le +).
  static String? phoneE164(String trimmedValue) {
    if (trimmedValue.isEmpty) {
      return AuthStrings.loginValidationPhoneEmpty;
    }
    final ok = RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(trimmedValue);
    if (!ok) return AuthStrings.loginValidationPhoneInvalid;
    return null;
  }

  static String? otpCode(String value) {
    final t = value.trim();
    if (t.isEmpty) return AuthStrings.loginValidationOtpEmpty;
    if (t.length < 6) return AuthStrings.loginValidationOtpTooShort;
    return null;
  }
}


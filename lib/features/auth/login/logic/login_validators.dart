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
}

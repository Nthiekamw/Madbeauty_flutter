import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/constants/app_strings.dart';
import 'package:madbeauty/features/auth/login/logic/login_validators.dart';

void main() {
  group('LoginValidators.email', () {
    test('retourne une erreur si email vide', () {
      expect(
        LoginValidators.email(''),
        AppStrings.loginValidationEmailEmpty,
      );
    });

    test('retourne une erreur si email invalide', () {
      expect(
        LoginValidators.email('no-at-symbol'),
        AppStrings.loginValidationEmailInvalid,
      );
    });

    test('retourne null si email valide', () {
      expect(LoginValidators.email('test@madbeauty.app'), isNull);
    });
  });

  group('LoginValidators.password', () {
    test('retourne une erreur si mot de passe vide', () {
      expect(
        LoginValidators.password(''),
        AppStrings.loginValidationPasswordEmpty,
      );
    });

    test('retourne null si mot de passe non vide', () {
      expect(LoginValidators.password('secret123'), isNull);
    });
  });
}

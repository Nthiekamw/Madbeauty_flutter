import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/constants/app_strings.dart';
import 'package:madbeauty/features/auth/register/logic/register_validators.dart';

void main() {
  group('RegisterValidators.name', () {
    test('retourne une erreur si nom vide', () {
      expect(
        RegisterValidators.name(''),
        AuthStrings.registerValidationNameEmpty,
      );
    });

    test('retourne null si nom valide', () {
      expect(RegisterValidators.name('Jason Doe'), isNull);
    });
  });

  group('RegisterValidators.email', () {
    test('retourne une erreur si email vide', () {
      expect(
        RegisterValidators.email(''),
        AuthStrings.registerValidationEmailEmpty,
      );
    });

    test('retourne une erreur si email invalide', () {
      expect(
        RegisterValidators.email('invalid-email'),
        AuthStrings.registerValidationEmailInvalid,
      );
    });

    test('retourne null si email valide', () {
      expect(RegisterValidators.email('register@madbeauty.app'), isNull);
    });
  });

  group('RegisterValidators.password', () {
    test('retourne une erreur si mot de passe vide', () {
      expect(
        RegisterValidators.password(''),
        AuthStrings.registerValidationPasswordEmpty,
      );
    });

    test('retourne null si mot de passe non vide', () {
      expect(RegisterValidators.password('strong-password'), isNull);
    });
  });
}

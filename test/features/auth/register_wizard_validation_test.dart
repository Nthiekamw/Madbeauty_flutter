import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/features/auth/register/logic/register_wizard_validation.dart';

void main() {
  group('RegisterWizardValidation.validateStep0', () {
    const base = (
      phone: '612345678',
      dialCode: '+33',
      email: 'test@example.com',
      password: 'secret12',
      confirmPassword: 'secret12',
    );

    test('exige prénom et nom sans OAuth', () {
      final errors = RegisterWizardValidation.validateStep0(
        prenom: '',
        nom: '',
        phone: base.phone,
        dialCode: base.dialCode,
        email: base.email,
        password: base.password,
        confirmPassword: base.confirmPassword,
        signedUpViaOAuth: false,
      );

      expect(errors.prenomError, isNotNull);
      expect(errors.nomError, isNotNull);
      expect(errors.step0Valid, isFalse);
    });

    test('ignore prénom/nom fournis par OAuth', () {
      final errors = RegisterWizardValidation.validateStep0(
        prenom: '',
        nom: '',
        phone: base.phone,
        dialCode: base.dialCode,
        email: base.email,
        password: base.password,
        confirmPassword: base.confirmPassword,
        signedUpViaOAuth: true,
        oauthProvidedPrenom: true,
        oauthProvidedNom: true,
      );

      expect(errors.prenomError, isNull);
      expect(errors.nomError, isNull);
      expect(errors.emailError, isNull);
      expect(errors.passwordError, isNull);
      expect(errors.step0Valid, isTrue);
    });

    test('Sign in with Apple : jamais exiger prénom/nom/e-mail', () {
      final errors = RegisterWizardValidation.validateStep0(
        prenom: '',
        nom: '',
        phone: base.phone,
        dialCode: base.dialCode,
        email: '',
        password: '',
        confirmPassword: '',
        signedUpViaOAuth: true,
        signedUpViaApple: true,
        oauthProvidedPrenom: false,
        oauthProvidedNom: false,
      );

      expect(errors.prenomError, isNull);
      expect(errors.nomError, isNull);
      expect(errors.emailError, isNull);
      expect(errors.passwordError, isNull);
      expect(errors.step0Valid, isTrue);
    });

    test('exige encore le nom si seul le prénom vient d OAuth', () {
      final errors = RegisterWizardValidation.validateStep0(
        prenom: 'Ada',
        nom: '',
        phone: base.phone,
        dialCode: base.dialCode,
        email: base.email,
        password: base.password,
        confirmPassword: base.confirmPassword,
        signedUpViaOAuth: true,
        oauthProvidedPrenom: true,
        oauthProvidedNom: false,
      );

      expect(errors.prenomError, isNull);
      expect(errors.nomError, isNotNull);
    });
  });
}

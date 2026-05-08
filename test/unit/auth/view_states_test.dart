import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/features/auth/login/models/login_view_state.dart';
import 'package:madbeauty/features/auth/register/models/register_view_state.dart';

void main() {
  group('LoginViewState.copyWith', () {
    test('conserve les valeurs existantes par defaut', () {
      const initial = LoginViewState(
        emailError: 'email',
        passwordError: 'password',
        submitError: 'submit',
        requestSupabaseSnack: true,
        shouldPopRoute: true,
      );

      final copy = initial.copyWith();

      expect(copy.emailError, 'email');
      expect(copy.passwordError, 'password');
      expect(copy.submitError, 'submit');
      expect(copy.requestSupabaseSnack, isTrue);
      expect(copy.shouldPopRoute, isTrue);
    });

    test('efface les erreurs ciblees avec les flags clear', () {
      const initial = LoginViewState(
        emailError: 'email',
        passwordError: 'password',
        submitError: 'submit',
      );

      final copy = initial.copyWith(
        clearEmailError: true,
        clearPasswordError: true,
        clearSubmitError: true,
      );

      expect(copy.emailError, isNull);
      expect(copy.passwordError, isNull);
      expect(copy.submitError, isNull);
    });
  });

  group('RegisterViewState.copyWith', () {
    test('met a jour les booleans sans perdre les autres valeurs', () {
      const initial = RegisterViewState(
        nameError: 'name',
        emailError: 'email',
        passwordError: 'password',
      );

      final copy = initial.copyWith(
        requestSupabaseSnack: true,
        shouldPopRoute: true,
      );

      expect(copy.nameError, 'name');
      expect(copy.emailError, 'email');
      expect(copy.passwordError, 'password');
      expect(copy.requestSupabaseSnack, isTrue);
      expect(copy.shouldPopRoute, isTrue);
    });

    test('efface les erreurs ciblees avec les flags clear', () {
      const initial = RegisterViewState(
        nameError: 'name',
        emailError: 'email',
        passwordError: 'password',
        submitError: 'submit',
      );

      final copy = initial.copyWith(
        clearNameError: true,
        clearEmailError: true,
        clearPasswordError: true,
        clearSubmitError: true,
      );

      expect(copy.nameError, isNull);
      expect(copy.emailError, isNull);
      expect(copy.passwordError, isNull);
      expect(copy.submitError, isNull);
    });
  });
}

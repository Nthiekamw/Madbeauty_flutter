import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madbeauty/core/constants/app_strings.dart';
import 'package:madbeauty/features/auth/login/models/login_view_state.dart';
import 'package:madbeauty/features/auth/login/providers/login_controller.dart';

void main() {
  group('LoginController', () {
    test('submit retourne erreurs de validation', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(loginControllerProvider, (_, __) {});

      await container.read(loginControllerProvider.notifier).submit(
            rawEmail: 'invalid-email',
            rawPassword: '',
          );

      final state = container.read(loginControllerProvider);
      expect(state.emailError, AuthStrings.loginValidationEmailInvalid);
      expect(state.passwordError, AuthStrings.loginValidationPasswordEmpty);
      expect(state.requestSupabaseSnack, isFalse);
    });

    test('submit demande snack si supabase absent', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(loginControllerProvider, (_, __) {});

      await container.read(loginControllerProvider.notifier).submit(
            rawEmail: 'user@madbeauty.app',
            rawPassword: 'password123',
          );

      final state = container.read(loginControllerProvider);
      expect(state.requestSupabaseSnack, isTrue);
      expect(state.shouldPopRoute, isFalse);
      expect(state.submitError, isNull);
    });

    test('onEmailChanged efface emailError et submitError', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(loginControllerProvider, (_, __) {});
      container.read(loginControllerProvider.notifier).state =
          const LoginViewState(
            emailError: 'email',
            passwordError: 'password',
            submitError: 'submit',
            requestSupabaseSnack: true,
            shouldPopRoute: true,
          );

      container.read(loginControllerProvider.notifier).onEmailChanged('a');
      final state = container.read(loginControllerProvider);

      expect(state.emailError, isNull);
      expect(state.submitError, isNull);
      expect(state.passwordError, 'password');
    });

    test('acknowledge methods remettent flags a false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(loginControllerProvider, (_, __) {});
      container.read(loginControllerProvider.notifier).state =
          const LoginViewState(
            emailError: 'email',
            passwordError: 'password',
            submitError: 'submit',
            requestSupabaseSnack: true,
            shouldPopRoute: true,
          );

      final notifier = container.read(loginControllerProvider.notifier);
      notifier.acknowledgeSupabaseSnack();
      notifier.acknowledgeRouteClose();
      final state = container.read(loginControllerProvider);

      expect(state.requestSupabaseSnack, isFalse);
      expect(state.shouldPopRoute, isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madbeauty/core/constants/app_strings.dart';
import 'package:madbeauty/features/auth/register/models/register_view_state.dart';
import 'package:madbeauty/features/auth/register/providers/register_controller.dart';

void main() {
  group('RegisterController', () {
    test('submit retourne erreurs de validation', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(registerControllerProvider, (_, __) {});

      await container.read(registerControllerProvider.notifier).submit(
            rawName: '',
            rawEmail: 'invalid-email',
            rawPassword: '',
          );

      final state = container.read(registerControllerProvider);
      expect(state.nameError, AppStrings.registerValidationNameEmpty);
      expect(state.emailError, AppStrings.registerValidationEmailInvalid);
      expect(state.passwordError, AppStrings.registerValidationPasswordEmpty);
      expect(state.requestSupabaseSnack, isFalse);
    });

    test('submit demande snack si supabase absent', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(registerControllerProvider, (_, __) {});

      await container.read(registerControllerProvider.notifier).submit(
            rawName: 'Jason',
            rawEmail: 'user@madbeauty.app',
            rawPassword: 'password123',
          );

      final state = container.read(registerControllerProvider);
      expect(state.requestSupabaseSnack, isTrue);
      expect(state.shouldPopRoute, isFalse);
      expect(state.submitError, isNull);
    });

    test('onNameChanged efface nameError et submitError', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(registerControllerProvider, (_, __) {});
      container.read(registerControllerProvider.notifier).state =
          const RegisterViewState(
            nameError: 'name',
            emailError: 'email',
            passwordError: 'password',
            submitError: 'submit',
            requestSupabaseSnack: true,
            shouldPopRoute: true,
          );

      container.read(registerControllerProvider.notifier).onNameChanged('j');
      final state = container.read(registerControllerProvider);

      expect(state.nameError, isNull);
      expect(state.submitError, isNull);
      expect(state.emailError, 'email');
      expect(state.passwordError, 'password');
    });

    test('acknowledge methods remettent flags a false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(registerControllerProvider, (_, __) {});
      container.read(registerControllerProvider.notifier).state =
          const RegisterViewState(
            nameError: 'name',
            emailError: 'email',
            passwordError: 'password',
            submitError: 'submit',
            requestSupabaseSnack: true,
            shouldPopRoute: true,
          );

      final notifier = container.read(registerControllerProvider.notifier);
      notifier.acknowledgeSupabaseSnack();
      notifier.acknowledgeRouteClose();
      final state = container.read(registerControllerProvider);

      expect(state.requestSupabaseSnack, isFalse);
      expect(state.shouldPopRoute, isFalse);
    });
  });
}

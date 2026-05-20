import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_notifier.dart';

/// Indique qu’une session « réinitialisation mot de passe » est active (lien e-mail).
///
/// Quand [AuthChangeEvent.passwordRecovery] est émis, passe à `true` jusqu’à
/// [PasswordRecoveryNotifier.clear] (mot de passe mis à jour ou déconnexion).
final passwordRecoveryPendingProvider =
    NotifierProvider<PasswordRecoveryNotifier, bool>(
  PasswordRecoveryNotifier.new,
);

/// Session « mot de passe oublié » active (lien e-mail ouvert dans l’app).
final isPasswordRecoveryActiveProvider = Provider<bool>((ref) {
  if (ref.watch(passwordRecoveryPendingProvider)) return true;
  final authState = ref.watch(authStateStreamProvider);
  return authState.maybeWhen(
    data: (state) => state.event == AuthChangeEvent.passwordRecovery,
    orElse: () => false,
  );
});

class PasswordRecoveryNotifier extends Notifier<bool> {
  @override
  bool build() {
    ref.listen<AsyncValue<AuthState>>(
      authStateStreamProvider,
      (previous, next) {
        next.when(
          data: (authState) {
            switch (authState.event) {
              case AuthChangeEvent.passwordRecovery:
                state = true;
              case AuthChangeEvent.signedOut:
                state = false;
              default:
                break;
            }
          },
          error: (_, __) {},
          loading: () {},
        );
      },
      fireImmediately: true,
    );
    return false;
  }

  void clear() => state = false;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import 'biometric_auth_service.dart';

final biometricAuthServiceProvider = Provider<BiometricAuthService>(
  (ref) => BiometricAuthService(LocalAuthentication()),
);

final biometricAvailabilityProvider = FutureProvider<BiometricAvailability>(
  (ref) => ref.watch(biometricAuthServiceProvider).checkAvailability(),
);

/// `true` après un déverrouillage biométrique réussi dans cette session d’app.
final biometricUnlockSessionProvider =
    NotifierProvider<BiometricUnlockSessionNotifier, bool>(
  BiometricUnlockSessionNotifier.new,
);

class BiometricUnlockSessionNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void unlock() => state = true;

  void lock() => state = false;
}

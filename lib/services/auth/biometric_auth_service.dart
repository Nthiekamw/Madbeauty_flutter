import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/constants/app_strings.dart';

/// Disponibilité biométrique sur l’appareil (Face ID, Touch ID, empreinte).
class BiometricAvailability {
  const BiometricAvailability({
    required this.supportedOnPlatform,
    required this.canAuthenticate,
    required this.label,
  });

  final bool supportedOnPlatform;
  final bool canAuthenticate;
  final String label;

  bool get isUsable => supportedOnPlatform && canAuthenticate;
}

/// Déverrouillage local via biométrie (ne remplace pas la connexion Supabase).
class BiometricAuthService {
  BiometricAuthService(this._localAuth);

  final LocalAuthentication _localAuth;

  static bool get isPlatformSupported {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.android => true,
      _ => false,
    };
  }

  Future<BiometricAvailability> checkAvailability() async {
    if (!isPlatformSupported) {
      return const BiometricAvailability(
        supportedOnPlatform: false,
        canAuthenticate: false,
        label: DiscProfile.prefBiometricGenericLabel,
      );
    }

    try {
      final deviceSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      final types = await _localAuth.getAvailableBiometrics();
      final label = _labelFor(types);
      return BiometricAvailability(
        supportedOnPlatform: deviceSupported,
        canAuthenticate: canCheck && types.isNotEmpty,
        label: label,
      );
    } catch (_) {
      return const BiometricAvailability(
        supportedOnPlatform: false,
        canAuthenticate: false,
        label: DiscProfile.prefBiometricGenericLabel,
      );
    }
  }

  Future<bool> authenticate({required String reason}) async {
    final availability = await checkAvailability();
    if (!availability.isUsable) return false;

    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  String _labelFor(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return DiscProfile.prefBiometricFaceIdLabel;
    }
    if (types.contains(BiometricType.fingerprint)) {
      return DiscProfile.prefBiometricFingerprintLabel;
    }
    if (types.contains(BiometricType.strong) ||
        types.contains(BiometricType.weak)) {
      return DiscProfile.prefBiometricGenericLabel;
    }
    return DiscProfile.prefBiometricGenericLabel;
  }
}

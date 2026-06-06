import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/failure_mapper.dart';
import '../../firebase_runtime_helpers.dart';
import 'auth_service.dart';

/// Session OTP en cours (Firebase ou Supabase).
class PhoneOtpPending {
  const PhoneOtpPending({
    required this.phoneE164,
    required this.viaFirebase,
    this.firebaseVerificationId,
    this.autoVerified = false,
  });

  final String phoneE164;
  final bool viaFirebase;
  final String? firebaseVerificationId;

  /// Vérification automatique (Android) : session déjà ouverte, pas de code à saisir.
  final bool autoVerified;
}

/// Envoi / vérification OTP téléphone.
///
/// Par défaut **Supabase OTP** (session directe). Firebase n’est utilisé que si
/// [kUseFirebasePhoneOtp] est activé et que l’envoi réussit sans erreur de config.
class PhoneAuthService {
  PhoneAuthService(this._auth);

  /// Bascule à `true` seulement quand SHA Firebase + provider Firebase dans
  /// Supabase sont configurés.
  static const bool kUseFirebasePhoneOtp = false;

  final AuthService _auth;

  bool get _canTryFirebase =>
      kUseFirebasePhoneOtp && isFirebaseConfiguredForPush();

  Future<PhoneOtpPending> sendOtp({
    required String phoneE164,
    bool shouldCreateUser = true,
  }) async {
    if (_canTryFirebase) {
      try {
        return await _sendFirebaseOtp(phoneE164);
      } on AppFailure catch (e) {
        if (FailureMapper.isFirebasePhoneSetupFailure(e)) {
          if (kDebugMode) {
            debugPrint(
              'PhoneAuthService: Firebase SMS indisponible (${e.cause}), '
              'bascule Supabase OTP.',
            );
          }
          return _sendSupabaseOtp(
            phoneE164: phoneE164,
            shouldCreateUser: shouldCreateUser,
          );
        }
        rethrow;
      }
    }
    return _sendSupabaseOtp(
      phoneE164: phoneE164,
      shouldCreateUser: shouldCreateUser,
    );
  }

  Future<PhoneOtpPending> _sendSupabaseOtp({
    required String phoneE164,
    required bool shouldCreateUser,
  }) async {
    await _auth.signInWithOtpPhone(
      phone: phoneE164,
      shouldCreateUser: shouldCreateUser,
    );
    return PhoneOtpPending(phoneE164: phoneE164, viaFirebase: false);
  }

  Future<AuthResponse> verifyOtp({
    required PhoneOtpPending pending,
    required String code,
  }) async {
    final token = code.trim();
    if (pending.viaFirebase) {
      final verificationId = pending.firebaseVerificationId;
      if (verificationId == null || verificationId.isEmpty) {
        throw AppFailure(
          FailureMapper.firebasePhoneSessionExpiredMessage,
        );
      }
      final credential = fb.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: token,
      );
      return _signInWithFirebaseCredential(credential);
    }
    return _auth.verifyOtpSmsSignIn(phone: pending.phoneE164, token: token);
  }

  Future<PhoneOtpPending> _sendFirebaseOtp(String phoneE164) async {
    await ensureFirebaseInitialized();

    final codeSent = Completer<void>();
    String? verificationId;
    fb.PhoneAuthCredential? autoCredential;
    Object? failure;

    await fb.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneE164,
      timeout: const Duration(seconds: 120),
      verificationCompleted: (credential) {
        autoCredential = credential;
        if (!codeSent.isCompleted) codeSent.complete();
      },
      verificationFailed: (e) {
        failure = e;
        if (!codeSent.isCompleted) codeSent.complete();
      },
      codeSent: (verId, _) {
        verificationId = verId;
        if (!codeSent.isCompleted) codeSent.complete();
      },
      codeAutoRetrievalTimeout: (verId) {
        verificationId ??= verId;
      },
    );

    await codeSent.future;

    if (failure != null) {
      final err = failure;
      if (err is fb.FirebaseAuthException) {
        throw FailureMapper.fromFirebaseAuthException(err);
      }
      throw FailureMapper.fromUnknown(err!);
    }

    final auto = autoCredential;
    if (auto != null) {
      await _signInWithFirebaseCredential(auto);
      return PhoneOtpPending(
        phoneE164: phoneE164,
        viaFirebase: true,
        firebaseVerificationId: verificationId,
        autoVerified: true,
      );
    }

    final verId = verificationId;
    if (verId == null || verId.isEmpty) {
      throw AppFailure(
        FailureMapper.firebasePhoneSessionExpiredMessage,
      );
    }

    return PhoneOtpPending(
      phoneE164: phoneE164,
      viaFirebase: true,
      firebaseVerificationId: verId,
    );
  }

  Future<AuthResponse> _signInWithFirebaseCredential(
    fb.PhoneAuthCredential credential,
  ) async {
    try {
      final result = await fb.FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final idToken = await result.user?.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        throw AppFailure(FailureMapper.firebasePhoneTokenMissingMessage);
      }
      return await _auth.signInWithFirebaseIdToken(idToken: idToken);
    } on fb.FirebaseAuthException catch (e) {
      throw FailureMapper.fromFirebaseAuthException(e);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw FailureMapper.fromUnknown(e);
    }
  }
}

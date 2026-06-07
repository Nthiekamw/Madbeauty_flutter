import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_strings.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/failure_mapper.dart';
import '../../firebase_runtime_helpers.dart';
import 'auth_service.dart';

/// Session OTP Firebase en cours.
class PhoneOtpPending {
  const PhoneOtpPending({
    required this.phoneE164,
    this.firebaseVerificationId,
    this.autoVerified = false,
  });

  final String phoneE164;
  final String? firebaseVerificationId;

  /// Vérification automatique (Android) : session déjà ouverte, pas de code à saisir.
  final bool autoVerified;
}

/// OTP téléphone **uniquement via Firebase** (SMS natif + jeton échangé contre une session Supabase).
class PhoneAuthService {
  PhoneAuthService(this._auth);

  final AuthService _auth;

  Future<PhoneOtpPending> sendOtp({
    required String phoneE164,
    bool shouldCreateUser = true,
  }) async {
    if (!isFirebaseConfiguredForPush()) {
      throw AppFailure(AuthStrings.authPhoneFirebaseAppNotConfigured);
    }
    return _sendFirebaseOtp(phoneE164);
  }

  Future<AuthResponse> verifyOtp({
    required PhoneOtpPending pending,
    required String code,
  }) async {
    final verificationId = pending.firebaseVerificationId;
    if (verificationId == null || verificationId.isEmpty) {
      throw AppFailure(FailureMapper.firebasePhoneSessionExpiredMessage);
    }
    final credential = fb.PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: code.trim(),
    );
    return _signInWithFirebaseCredential(credential);
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
        firebaseVerificationId: verificationId,
        autoVerified: true,
      );
    }

    final verId = verificationId;
    if (verId == null || verId.isEmpty) {
      throw AppFailure(FailureMapper.firebasePhoneSessionExpiredMessage);
    }

    return PhoneOtpPending(
      phoneE164: phoneE164,
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

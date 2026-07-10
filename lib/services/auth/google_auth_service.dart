import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/constants/app_strings.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/failure_mapper.dart';
import 'google_sign_in_result.dart';
import 'auth_service.dart';

/// Connexion Google native → jeton Google → session Supabase.
class GoogleAuthService {
  GoogleAuthService(this._auth);

  static const Duration authenticateTimeout = Duration(seconds: 30);
  static const Duration supabaseExchangeTimeout = Duration(seconds: 15);

  static const String firebaseWebClientId =
      '138830696039-v93u9uvt39ugt7vu5ern1mohgf1078dg.apps.googleusercontent.com';

  static const String firebaseIosClientId =
      '138830696039-hi486049vacsddcuq5lfu9611ag8omaj.apps.googleusercontent.com';

  static bool _googleSignInInitialized = false;
  static Completer<void>? _initCompleter;

  final AuthService _auth;

  /// Google natif (Android/iOS) — indépendant de Firebase Auth / FCM.
  bool get canUseNativeGoogle => isNativeGoogleSignInAvailable();

  static bool isNativeGoogleSignInAvailable() {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return firebaseWebClientId.trim().isNotEmpty;
      default:
        return false;
    }
  }

  static Future<void> warmUp() async {
    if (!isNativeGoogleSignInAvailable()) return;
    await _ensureGoogleSignInReady();
  }

  static Future<void> _ensureGoogleSignInReady() async {
    if (_googleSignInInitialized) return;
    if (_initCompleter != null) {
      await _initCompleter!.future;
      return;
    }
    _initCompleter = Completer<void>();
    try {
      await GoogleSignIn.instance.initialize(
        clientId: defaultTargetPlatform == TargetPlatform.iOS
            ? firebaseIosClientId
            : null,
        serverClientId: firebaseWebClientId,
      );
      _googleSignInInitialized = true;
      _initCompleter!.complete();
    } catch (e, st) {
      _initCompleter!.completeError(e, st);
      _initCompleter = null;
      if (kDebugMode) debugPrint('[GoogleAuth] warmUp failed: $e\n$st');
      rethrow;
    }
  }

  Future<GoogleSignInResult> signInWithGoogleNative() async {
    await warmUp();

    try {
      // google_sign_in 7.x : authenticate() sans signOut préalable peut bloquer.
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        /* best-effort */
      }

      if (kDebugMode) debugPrint('[GoogleAuth] authenticate…');
      final googleUser = await GoogleSignIn.instance
          .authenticate()
          .timeout(authenticateTimeout);

      final googleIdToken = googleUser.authentication.idToken;
      if (googleIdToken == null || googleIdToken.isEmpty) {
        throw AppFailure(AuthStrings.authGoogleSupabaseLinkFailed);
      }

      if (kDebugMode) {
        debugPrint('[GoogleAuth] id_token OK → Supabase signInWithIdToken');
      }

      final response = await _auth
          .signInWithGoogleIdToken(idToken: googleIdToken)
          .timeout(supabaseExchangeTimeout);
      return GoogleSignInResult(response: response, account: googleUser);
    } on TimeoutException {
      throw AppFailure(AuthStrings.authGoogleSignInTimeout);
    } on AppFailure {
      rethrow;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AppFailure(AuthStrings.authGoogleSignInCanceled);
      }
      if (FailureMapper.isGoogleSignInSetupError(e)) {
        throw AppFailure(AuthStrings.authGoogleFirebaseNotConfigured, cause: e);
      }
      throw FailureMapper.fromUnknown(e);
    } catch (e, st) {
      if (kDebugMode) debugPrint('[GoogleAuth] unexpected: $e\n$st');
      throw FailureMapper.fromUnknown(e);
    }
  }
}

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../core/constants/app_strings.dart';
import '../../core/errors/app_failure.dart';
import '../../core/errors/failure_mapper.dart';
import 'apple_sign_in_result.dart';
import 'auth_service.dart';

/// Connexion Apple native → id_token → session Supabase.
class AppleAuthService {
  AppleAuthService(this._auth);

  final AuthService _auth;

  bool get canUseNativeApple => isNativeAppleSignInAvailable();

  static bool isNativeAppleSignInAvailable() {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      default:
        return false;
    }
  }

  Future<AppleSignInResult> signInWithAppleNative() async {
    if (!isNativeAppleSignInAvailable()) {
      throw AppFailure(AuthStrings.authAppleUnavailable);
    }

    final rawNonce = _auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    try {
      if (kDebugMode) debugPrint('[AppleAuth] authenticate…');

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw AppFailure(AuthStrings.authAppleSupabaseLinkFailed);
      }

      if (kDebugMode) {
        debugPrint('[AppleAuth] id_token OK → Supabase signInWithIdToken');
      }

      final response = await _auth.signInWithAppleIdToken(
        idToken: idToken,
        nonce: rawNonce,
      );
      return AppleSignInResult(response: response, credential: credential);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw AppFailure(AuthStrings.authAppleSignInCanceled);
      }
      throw FailureMapper.fromUnknown(e);
    } on AppFailure {
      rethrow;
    } catch (e, st) {
      if (kDebugMode) debugPrint('[AppleAuth] unexpected: $e\n$st');
      throw FailureMapper.fromUnknown(e);
    }
  }
}

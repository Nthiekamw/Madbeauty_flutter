import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_strings.dart';
import 'app_failure.dart';

/// Conversion des erreurs SDK / réseau en [AppFailure] pour la couche app.
abstract final class FailureMapper {
  FailureMapper._();

  static AppFailure fromAuthException(AuthException e) {
    final msg = e.message.toLowerCase();
    final code = e.statusCode?.toLowerCase();
    final isEmailNotConfirmed = msg.contains('email not confirmed') ||
        msg.contains('email_not_confirmed') ||
        code == 'email_not_confirmed';

    if (isEmailNotConfirmed) {
      return AppFailure(AuthStrings.authEmailNotConfirmed, cause: e);
    }
    final isInvalidCredentials = msg.contains('invalid login credentials') ||
        msg.contains('invalid_credentials') ||
        msg.contains('email or password is incorrect');
    if (isInvalidCredentials) {
      return AppFailure(AuthStrings.loginInvalidCredentials, cause: e);
    }
    final isEmailInvalid = msg.contains('email_address_invalid') ||
        msg.contains('email address') && msg.contains('invalid');
    if (isEmailInvalid) {
      return AppFailure(AuthStrings.authEmailAddressInvalid, cause: e);
    }
    final isEmailNotAuthorized = msg.contains('email_address_not_authorized');
    if (isEmailNotAuthorized) {
      return AppFailure(AuthStrings.authEmailAddressNotAuthorized, cause: e);
    }
    final isEmailRateLimited = msg.contains('email rate limit exceeded') ||
        msg.contains('over_email_send_rate_limit') ||
        e.statusCode == '429';
    if (isEmailRateLimited) {
      return AppFailure(AuthStrings.authEmailRateLimitExceeded, cause: e);
    }
    final isSmsOtpInvalid = msg.contains('token has expired') ||
        msg.contains('otp_expired') ||
        msg.contains('invalid otp');
    if (isSmsOtpInvalid) {
      return AppFailure(AuthStrings.authPhoneOtpInvalid, cause: e);
    }
    final isPhoneRateLimited = msg.contains('sms rate limit') ||
        msg.contains('over_sms_send_rate_limit');
    if (isPhoneRateLimited) {
      return AppFailure(AuthStrings.authPhoneRateLimitExceeded, cause: e);
    }
    final isPhoneProviderMissing = msg.contains('unsupported phone provider') ||
        msg.contains('phone_provider_disabled') ||
        msg.contains('sms provider') && msg.contains('could not be found') ||
        code == 'phone_provider_disabled';
    if (isPhoneProviderMissing) {
      return AppFailure(AuthStrings.authPhoneProviderUnsupported, cause: e);
    }
    final isProviderLink = msg.contains('provider') &&
            (msg.contains('firebase') || msg.contains('disabled')) ||
        msg.contains('id_token') ||
        msg.contains('sign_in_with_id_token');
    if (isProviderLink) {
      return AppFailure(AuthStrings.authPhoneSupabaseLinkFailed, cause: e);
    }
    return AppFailure(e.message, cause: e);
  }

  static String get firebasePhoneSessionExpiredMessage =>
      AuthStrings.authPhoneOtpSessionExpired;

  static String get firebasePhoneTokenMissingMessage =>
      AuthStrings.authPhoneFirebaseTokenMissing;

  static bool isFirebasePhoneSetupError(fb.FirebaseAuthException e) {
    final code = e.code.toLowerCase();
    final msg = (e.message ?? '').toLowerCase();
    return code == 'invalid-cert-hash' ||
        code == 'missing-app-identifier' ||
        code == 'app-not-authorized' ||
        msg.contains('invalid_cert_hash') ||
        msg.contains('certificate hash') ||
        msg.contains('app identifier') ||
        msg.contains('play integrity') ||
        msg.contains('recaptcha') ||
        msg.contains('17093');
  }

  static AppFailure fromFirebaseAuthException(fb.FirebaseAuthException e) {
    final code = e.code.toLowerCase();
    if (isFirebasePhoneSetupError(e)) {
      return AppFailure(AuthStrings.authPhoneFirebaseAppNotConfigured, cause: e);
    }
    if (code == 'invalid-verification-code' ||
        code == 'session-expired' ||
        code == 'code-expired') {
      return AppFailure(
        code == 'session-expired' || code == 'code-expired'
            ? AuthStrings.authPhoneOtpAlreadyUsed
            : AuthStrings.authPhoneOtpInvalid,
        cause: e,
      );
    }
    if (code == 'too-many-requests' || code == 'quota-exceeded') {
      return AppFailure(AuthStrings.authPhoneRateLimitExceeded, cause: e);
    }
    if (code == 'invalid-phone-number') {
      return AppFailure(AuthStrings.loginValidationPhoneInvalid, cause: e);
    }
    final msg = e.message;
    if (msg != null && msg.trim().isNotEmpty) {
      return AppFailure(msg.trim(), cause: e);
    }
    return AppFailure(CoreStrings.errorUnexpected, cause: e);
  }

  static bool isFirebasePhoneSetupFailure(AppFailure failure) {
    final cause = failure.cause;
    if (cause is fb.FirebaseAuthException) {
      return isFirebasePhoneSetupError(cause);
    }
    return failure.message == AuthStrings.authPhoneFirebaseAppNotConfigured;
  }

  static AppFailure fromPostgrestException(PostgrestException e) {
    final msg = e.message.trim();
    if (msg.isNotEmpty) {
      return AppFailure(msg, cause: e);
    }
    return AppFailure(CoreStrings.errorUnexpected, cause: e);
  }

  static AppFailure fromUnknown(Object error) =>
      AppFailure(CoreStrings.errorUnexpected, cause: error);
}


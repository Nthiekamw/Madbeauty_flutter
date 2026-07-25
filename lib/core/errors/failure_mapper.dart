import 'package:google_sign_in/google_sign_in.dart';
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
    final isProviderLink = msg.contains('provider') &&
            (msg.contains('firebase') || msg.contains('disabled')) ||
        msg.contains('id_token') ||
        msg.contains('sign_in_with_id_token');
    if (isProviderLink) {
      return AppFailure(AuthStrings.authGoogleSupabaseLinkFailed, cause: e);
    }
    return AppFailure(e.message, cause: e);
  }

  static bool isGoogleSignInSetupError(GoogleSignInException e) {
    return e.code == GoogleSignInExceptionCode.clientConfigurationError ||
        e.code == GoogleSignInExceptionCode.providerConfigurationError ||
        e.code == GoogleSignInExceptionCode.uiUnavailable;
  }

  /// `canceled` est souvent un faux positif (SHA-1 manquant, « Account reauth failed »).
  static bool isGoogleSignInFakeCancel(GoogleSignInException e) {
    if (e.code != GoogleSignInExceptionCode.canceled) return false;
    final detail = '${e.description ?? ''} ${e.details ?? ''}'.toLowerCase();
    if (detail.trim().isEmpty) return false;
    return detail.contains('reauth') ||
        detail.contains('sha') ||
        detail.contains('10:') ||
        detail.contains('12500') ||
        detail.contains('developer_error') ||
        detail.contains('api_exception') ||
        detail.contains('network_error') ||
        detail.contains('sign_in_failed') ||
        detail.contains('sign in failed') ||
        detail.contains('current activity is null');
  }

  static AppFailure fromGoogleSignInException(GoogleSignInException e) {
    if (isGoogleSignInSetupError(e) || isGoogleSignInFakeCancel(e)) {
      return AppFailure(
        AuthStrings.authGoogleNativeConfigFailed,
        cause: e,
      );
    }
    if (e.code == GoogleSignInExceptionCode.canceled) {
      return AppFailure(AuthStrings.authGoogleSignInCanceled, cause: e);
    }
    if (e.code == GoogleSignInExceptionCode.interrupted) {
      return AppFailure(AuthStrings.authGoogleSignInTimeout, cause: e);
    }
    final description = e.description?.trim();
    if (description != null && description.isNotEmpty) {
      return AppFailure(description, cause: e);
    }
    return AppFailure(CoreStrings.errorUnexpected, cause: e);
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

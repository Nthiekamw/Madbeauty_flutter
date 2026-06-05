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
    return AppFailure(e.message, cause: e);
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


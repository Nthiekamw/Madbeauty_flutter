import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_strings.dart';
import 'app_failure.dart';

/// Conversion des erreurs SDK / réseau en [AppFailure] pour la couche app.
abstract final class FailureMapper {
  FailureMapper._();

  static AppFailure fromAuthException(AuthException e) =>
      AppFailure(e.message, cause: e);

  static AppFailure fromUnknown(Object error) =>
      AppFailure(AppStrings.errorUnexpected, cause: error);
}

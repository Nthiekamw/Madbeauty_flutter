import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_strings.dart';
import 'app_failure.dart';
import 'supabase_service_exception.dart';

abstract final class SupabaseErrorHandler {
  SupabaseErrorHandler._();

  static Future<T> run<T>({
    required String operation,
    required Future<T> Function() action,
  }) async {
    try {
      return await action();
    } on SupabaseServiceException {
      rethrow;
    } on PostgrestException catch (e) {
      throw _fromPostgrest(operation, e);
    } on StorageException catch (e) {
      throw _fromStorage(operation, e);
    } on AuthException catch (e) {
      throw SupabaseServiceException(
        operation: operation,
        code: e.statusCode,
        message: e.message,
        cause: e,
      );
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw SupabaseServiceException(
        operation: operation,
        message: CoreStrings.errorUnexpected,
        cause: e,
      );
    }
  }

  static SupabaseServiceException _fromPostgrest(
    String operation,
    PostgrestException e,
  ) {
    return SupabaseServiceException(
      operation: operation,
      code: e.code,
      message: e.code == '42501'
          ? AuthStrings.roleChoiceSyncForbidden
          : _messageOrFallback(e.message),
      cause: e,
    );
  }

  static SupabaseServiceException _fromStorage(
    String operation,
    StorageException e,
  ) {
    return SupabaseServiceException(
      operation: operation,
      code: e.statusCode,
      message: _messageOrFallback(e.message),
      cause: e,
    );
  }

  static String _messageOrFallback(String? message) {
    final trimmed = message?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return CoreStrings.errorUnexpected;
    }
    return trimmed;
  }
}

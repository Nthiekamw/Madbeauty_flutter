import 'package:flutter/foundation.dart';
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
    } on PostgrestException catch (e, st) {
      _logRawError(
        operation: operation,
        kind: 'postgrest',
        code: e.code,
        message: e.message,
        error: e,
        stackTrace: st,
      );
      throw _fromPostgrest(operation, e);
    } on StorageException catch (e, st) {
      _logRawError(
        operation: operation,
        kind: 'storage',
        code: e.statusCode,
        message: e.message,
        error: e,
        stackTrace: st,
      );
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
    } catch (e, st) {
      _logRawError(
        operation: operation,
        kind: 'unknown',
        message: e.toString(),
        error: e,
        stackTrace: st,
      );
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
    final isRoleSyncOperation = operation.startsWith('role.');
    return SupabaseServiceException(
      operation: operation,
      code: e.code,
      message: (e.code == '42501' && isRoleSyncOperation)
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

  static void _logRawError({
    required String operation,
    required String kind,
    String? code,
    String? message,
    required Object error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;
    final codePart = (code == null || code.isEmpty) ? '-' : code;
    final msgPart = (message == null || message.trim().isEmpty)
        ? '(no-message)'
        : message.trim();
    debugPrint(
      '[SupabaseErrorHandler] op=$operation kind=$kind code=$codePart msg=$msgPart',
    );
    if (stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace, label: error.toString());
    }
  }
}


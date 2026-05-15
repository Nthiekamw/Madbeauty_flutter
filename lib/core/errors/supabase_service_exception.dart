import 'app_failure.dart';

class SupabaseServiceException extends AppFailure {
  const SupabaseServiceException({
    required String message,
    required this.operation,
    this.code,
    Object? cause,
  }) : super(message, cause: cause);

  final String operation;
  final String? code;

  @override
  String toString() {
    final suffix = code == null ? '' : ' ($code)';
    return 'SupabaseServiceException[$operation]$suffix: $message';
  }
}

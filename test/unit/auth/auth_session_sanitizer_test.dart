import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/services/auth/auth_session_sanitizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AuthSessionSanitizer.isStaleSessionError', () {
    test('détecte refresh_token_not_found', () {
      const error = AuthException(
        'Invalid Refresh Token: Refresh Token Not Found',
        statusCode: '400',
        code: 'refresh_token_not_found',
      );
      expect(AuthSessionSanitizer.isStaleSessionError(error), isTrue);
    });

    test('ignore les autres erreurs auth', () {
      const error = AuthException('Invalid login credentials', statusCode: '400');
      expect(AuthSessionSanitizer.isStaleSessionError(error), isFalse);
    });
  });
}

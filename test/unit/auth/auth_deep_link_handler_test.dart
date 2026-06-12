import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/router/app_deep_links.dart';
import 'package:madbeauty/services/auth/auth_deep_link_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AuthDeepLinkHandler', () {
    test('otpTypeFromQuery mappe signup et email', () {
      expect(AuthDeepLinkHandler.otpTypeFromQuery('signup'), OtpType.signup);
      expect(AuthDeepLinkHandler.otpTypeFromQuery('email'), OtpType.email);
      expect(AuthDeepLinkHandler.otpTypeFromQuery('recovery'), OtpType.recovery);
    });

    test('détecte type recovery dans query ou fragment', () {
      expect(
        AuthDeepLinkHandler.isPasswordRecoveryUri(
          Uri.parse(
            'com.madbeauty.madbeauty://login-callback'
            '?token_hash=hash123&type=recovery',
          ),
        ),
        isTrue,
      );
      expect(
        AuthDeepLinkHandler.isPasswordRecoveryUri(
          Uri.parse(
            'com.madbeauty.madbeauty://login-callback'
            '#access_token=abc&type=recovery',
          ),
        ),
        isTrue,
      );
      expect(
        AuthDeepLinkHandler.isPasswordRecoveryUri(
          Uri.parse(
            'com.madbeauty.madbeauty://login-callback?code=abc123',
          ),
        ),
        isFalse,
      );
    });

    test('normalise token_hash dans le fragment', () {
      final params = AuthDeepLinkHandler.normalizedQueryParameters(
        Uri.parse(
          'com.madbeauty.madbeauty://login-callback'
          '#token_hash=hash123&type=signup',
        ),
      );
      expect(params['token_hash'], 'hash123');
      expect(params['type'], 'signup');
      expect(
        AppDeepLinks.isAuthCallbackUri(
          Uri.parse(
            'com.madbeauty.madbeauty://login-callback'
            '#token_hash=hash123&type=signup',
          ),
        ),
        isTrue,
      );
    });
  });
}

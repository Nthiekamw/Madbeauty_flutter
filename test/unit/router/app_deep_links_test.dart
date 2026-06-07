import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/router/app_deep_links.dart';

void main() {
  group('AppDeepLinks', () {
    test('HTTPS /prestataire/:uuid', () {
      final path = AppDeepLinks.routePathFromUri(
        Uri.parse(
          'https://madbeauty.app/prestataire/11111111-1111-1111-1111-111111111111',
        ),
      );
      expect(
        path,
        '/prestataire/11111111-1111-1111-1111-111111111111',
      );
    });

    test('schéma custom com.madbeauty.madbeauty://prestataire/:uuid', () {
      final path = AppDeepLinks.routePathFromUri(
        Uri.parse(
          'com.madbeauty.madbeauty://prestataire/22222222-2222-2222-2222-222222222222',
        ),
      );
      expect(
        path,
        '/prestataire/22222222-2222-2222-2222-222222222222',
      );
    });

    test('ignore login-callback', () {
      expect(
        AppDeepLinks.routePathFromUri(
          Uri.parse('com.madbeauty.madbeauty://login-callback'),
        ),
        isNull,
      );
    });

    test('détecte login-callback avec code PKCE', () {
      expect(
        AppDeepLinks.isAuthCallbackUri(
          Uri.parse(
            'com.madbeauty.madbeauty://login-callback?code=abc123',
          ),
        ),
        isTrue,
      );
    });

    test('détecte login-callback avec token_hash inscription', () {
      expect(
        AppDeepLinks.isAuthCallbackUri(
          Uri.parse(
            'com.madbeauty.madbeauty://login-callback'
            '?token_hash=abc123&type=signup',
          ),
        ),
        isTrue,
      );
    });

    test('subscription-return → écran abonnement', () {
      expect(
        AppDeepLinks.subscriptionReturnPath(
          Uri.parse(
            'com.madbeauty.madbeauty://subscription-return?result=success',
          ),
        ),
        '/prestataire/subscription',
      );
    });

    test('HTTPS Supabase prestataire_share?prestataire_id=', () {
      final path = AppDeepLinks.routePathFromUri(
        Uri.parse(
          'https://vjjasrdoyguqkftfhaei.supabase.co/functions/v1/prestataire_share'
          '?prestataire_id=44444444-4444-4444-4444-444444444444',
        ),
      );
      expect(
        path,
        '/prestataire/44444444-4444-4444-4444-444444444444',
      );
    });

    test('legacy /prestataires/:id redirect', () {
      expect(
        AppDeepLinks.legacyListingRedirect(
          '/prestataires/33333333-3333-3333-3333-333333333333',
        ),
        '/prestataire/33333333-3333-3333-3333-333333333333',
      );
    });
  });
}

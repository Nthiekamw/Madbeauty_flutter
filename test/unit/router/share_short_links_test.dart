import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/config/share_link_config.dart';
import 'package:madbeauty/core/config/share_link_resolver.dart';
import 'package:madbeauty/core/models/domain/user/prestataire_public_slug.dart';
import 'package:madbeauty/router/app_deep_links.dart';

void main() {
  group('PrestatairePublicSlug', () {
    test('normalize @handle', () {
      expect(PrestatairePublicSlug.normalize('@Vichy'), 'vichy');
      expect(PrestatairePublicSlug.normalize(' beauty-glow '), 'beauty-glow');
      expect(PrestatairePublicSlug.normalize('Bad Slug!'), isNull);
    });
  });

  group('ShareLinkResolver short links', () {
    test('préférer /@slug en HTTPS', () {
      final url = ShareLinkResolver.prestataireProfileUrl(
        '11111111-1111-1111-1111-111111111111',
        publicSlug: 'vichy',
      );
      expect(url, contains('/@vichy'));
      expect(url, isNot(contains('functions/v1')));
    });

    test('fallback UUID sans slug', () {
      final url = ShareLinkResolver.prestataireProfileUrl(
        '11111111-1111-1111-1111-111111111111',
      );
      expect(
        url,
        '${ShareLinkConfig.httpsBaseUrl}/prestataire/11111111-1111-1111-1111-111111111111',
      );
    });
  });

  group('AppDeepLinks short handles', () {
    test('HTTPS /@slug', () {
      expect(
        AppDeepLinks.routePathFromUri(
          Uri.parse('https://madbeauty.pro/@vichy'),
        ),
        '/@vichy',
      );
    });

    test('HTTPS /p/slug', () {
      expect(
        AppDeepLinks.routePathFromUri(
          Uri.parse('https://madbeauty.pro/p/beauty-glow'),
        ),
        '/@beauty-glow',
      );
    });
  });
}

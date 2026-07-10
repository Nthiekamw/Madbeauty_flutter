import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/services/auth/oauth_identity_sync.dart';

void main() {
  group('OAuthNameParts', () {
    test('découpe un nom complet Google', () {
      final parts = OAuthNameParts.fromDisplayName('Inesse Djita');

      expect(parts.prenom, 'Inesse');
      expect(parts.nom, 'Djita');
    });

    test('ne force pas de nom si un seul mot', () {
      final parts = OAuthNameParts.fromDisplayName('Madonna');

      expect(parts.prenom, 'Madonna');
      expect(parts.nom, isNull);
    });

    test('lit full_name depuis les métadonnées Supabase', () {
      final parts = OAuthNameParts.fromMetadata({
        'full_name': 'Jason Nthiekam',
      });

      expect(parts.prenom, 'Jason');
      expect(parts.nom, 'Nthiekam');
    });
  });

  group('OAuthIdentityHints.fromMetadata', () {
    test('marque prénom/nom/e-mail fournis via full_name', () {
      final hints = OAuthIdentityHints.fromMetadata(
        {'full_name': 'Jason Nthiekam'},
        email: 'jason@example.com',
      );

      expect(hints.providedPrenom, isTrue);
      expect(hints.providedNom, isTrue);
      expect(hints.providedEmail, isTrue);
    });

    test('nom non fourni si full_name sur un seul mot', () {
      final hints = OAuthIdentityHints.fromMetadata(
        {'name': 'Madonna'},
        email: 'madonna@example.com',
      );

      expect(hints.providedPrenom, isTrue);
      expect(hints.providedNom, isFalse);
      expect(hints.providedEmail, isTrue);
    });
  });
}

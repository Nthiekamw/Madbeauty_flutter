import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/logic/messaging/chat_message_moderator.dart';

void main() {
  group('ChatMessageModerator.analyze', () {
    test('accepte un message normal', () {
      final r = ChatMessageModerator.analyze(
        'Bonjour, je serai là à 14h pour le rendez-vous.',
      );
      expect(r.isBlocked, isFalse);
    });

    test('bloque un numéro français', () {
      final r = ChatMessageModerator.analyze('Appelez-moi au 06 12 34 56 78');
      expect(r.isBlocked, isTrue);
      expect(r.primary, ChatMessageViolationType.phoneNumber);
    });

    test('bloque une adresse e-mail', () {
      final r = ChatMessageModerator.analyze('Écrivez à contact@exemple.fr');
      expect(r.isBlocked, isTrue);
      expect(r.primary, ChatMessageViolationType.email);
    });

    test('bloque un lien http', () {
      final r = ChatMessageModerator.analyze('Voir https://example.com/page');
      expect(r.isBlocked, isTrue);
      expect(r.primary, ChatMessageViolationType.externalLink);
    });

    test('bloque un IBAN', () {
      final r = ChatMessageModerator.analyze(
        'Mon IBAN FR76 3000 6000 0112 3456 7890 189',
      );
      expect(r.isBlocked, isTrue);
      expect(r.violations, contains(ChatMessageViolationType.bankDetails));
    });

    test('bloque une mention WhatsApp', () {
      final r = ChatMessageModerator.analyze('On continue sur whatsapp ?');
      expect(r.isBlocked, isTrue);
      expect(r.primary, ChatMessageViolationType.externalContact);
    });
  });

  group('ChatMessageModerator.sanitizeForDisplay', () {
    test('masque e-mail et téléphone', () {
      final out = ChatMessageModerator.sanitizeForDisplay(
        'mail: test@domain.com tel 0612345678',
      );
      expect(out, contains('•••@•••.••'));
      expect(out, isNot(contains('test@domain.com')));
    });
  });
}

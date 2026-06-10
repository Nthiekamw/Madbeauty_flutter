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

    test('bloque un fragment de numéro (6 chiffres)', () {
      final r = ChatMessageModerator.analyze('076285');
      expect(r.isBlocked, isTrue);
      expect(r.primary, ChatMessageViolationType.phoneNumber);
    });

    test('bloque un numéro envoyé en morceaux', () {
      final r = ChatMessageModerator.analyze(
        '5388',
        context: const ChatMessageModerationContext(
          recentOutgoingMessages: ['076285'],
        ),
      );
      expect(r.isBlocked, isTrue);
      expect(r.primary, ChatMessageViolationType.phoneNumber);
    });

    test('bloque une adresse e-mail', () {
      final r = ChatMessageModerator.analyze('Écrivez à contact@exemple.fr');
      expect(r.isBlocked, isTrue);
      expect(r.primary, ChatMessageViolationType.email);
    });

    test('bloque un e-mail en morceaux', () {
      final r = ChatMessageModerator.analyze(
        '@gmail.com',
        context: const ChatMessageModerationContext(
          recentOutgoingMessages: ['mon mail c est jean.dupont'],
        ),
      );
      expect(r.isBlocked, isTrue);
      expect(r.violations, contains(ChatMessageViolationType.email));
    });

    test('bloque le symbole @ seul', () {
      final r = ChatMessageModerator.analyze('jean.dupont@');
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

    test('bloque une adresse postale', () {
      final r = ChatMessageModerator.analyze('12 rue de la Paix 75002 Paris');
      expect(r.isBlocked, isTrue);
      expect(r.primary, ChatMessageViolationType.physicalAddress);
    });

    test('bloque une adresse en morceaux', () {
      final r = ChatMessageModerator.analyze(
        '75001 Paris',
        context: const ChatMessageModerationContext(
          recentOutgoingMessages: ['Je suis au 5 avenue de l Opéra'],
        ),
      );
      expect(r.isBlocked, isTrue);
      expect(r.violations, contains(ChatMessageViolationType.physicalAddress));
    });

    test('bloque une demande de numéro', () {
      final r = ChatMessageModerator.analyze(
        'Donnez-moi votre numéro de téléphone',
      );
      expect(r.isBlocked, isTrue);
      expect(r.primary, ChatMessageViolationType.contactSolicitation);
    });

    test('bloque une demande d e-mail', () {
      final r = ChatMessageModerator.analyze('Envoie-moi ton mail perso');
      expect(r.isBlocked, isTrue);
      expect(r.primary, ChatMessageViolationType.contactSolicitation);
    });

    test('bloque une insulte', () {
      final r = ChatMessageModerator.analyze('Espèce de connard');
      expect(r.isBlocked, isTrue);
      expect(r.primary, ChatMessageViolationType.insult);
    });

    test('bloque une insulte espacée', () {
      final r = ChatMessageModerator.analyze('c o n n a r d');
      expect(r.isBlocked, isTrue);
      expect(r.violations, contains(ChatMessageViolationType.insult));
    });

    test('bloque une insulte en morceaux', () {
      final r = ChatMessageModerator.analyze(
        'nard',
        context: const ChatMessageModerationContext(
          recentOutgoingMessages: ['con'],
        ),
      );
      expect(r.isBlocked, isTrue);
      expect(r.violations, contains(ChatMessageViolationType.insult));
    });

    test('bloque un contenu sexuel explicite', () {
      final r = ChatMessageModerator.analyze('On baise ce soir ?');
      expect(r.isBlocked, isTrue);
      expect(r.primary, ChatMessageViolationType.sexualContent);
    });

    test('bloque une demande de photo intime', () {
      final r = ChatMessageModerator.analyze('Envoie-moi une photo intime');
      expect(r.isBlocked, isTrue);
      expect(r.primary, ChatMessageViolationType.sexualContent);
    });

    test('accepte un message beauté courant', () {
      final r = ChatMessageModerator.analyze(
        'Le massage du visage est prévu à 15h, merci.',
      );
      expect(r.isBlocked, isFalse);
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

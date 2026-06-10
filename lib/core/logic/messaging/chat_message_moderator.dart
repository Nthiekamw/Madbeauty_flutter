import 'package:madbeauty/core/constants/app_strings.dart';

import 'chat_inappropriate_content.dart';

/// Type de contenu interdit dans la messagerie (sécurité plateforme).
enum ChatMessageViolationType {
  phoneNumber,
  email,
  externalLink,
  bankDetails,
  externalContact,
  physicalAddress,
  contactSolicitation,
  insult,
  sexualContent,
}

/// Messages récents du même expéditeur (anti-contournement par morceaux).
class ChatMessageModerationContext {
  const ChatMessageModerationContext({
    this.recentOutgoingMessages = const [],
  });

  /// Du plus ancien au plus récent (hors brouillon en cours).
  final List<String> recentOutgoingMessages;
}

/// Résultat de l'analyse d'un message avant envoi.
class ChatMessageModerationResult {
  const ChatMessageModerationResult({required this.violations});

  final List<ChatMessageViolationType> violations;

  static const none = ChatMessageModerationResult(violations: []);

  bool get isBlocked => violations.isNotEmpty;

  ChatMessageViolationType? get primary =>
      violations.isEmpty ? null : violations.first;

  String get bannerMessage {
    if (violations.isEmpty) return '';
    if (violations.length == 1) {
      return _messageFor(violations.first);
    }
    return DiscChat.moderationMultipleBlocked;
  }

  String get dialogTitle => DiscChat.moderationDialogTitle;

  String get dialogBody => bannerMessage;

  static String _messageFor(ChatMessageViolationType type) {
    return switch (type) {
      ChatMessageViolationType.phoneNumber => DiscChat.moderationPhoneBlocked,
      ChatMessageViolationType.email => DiscChat.moderationEmailBlocked,
      ChatMessageViolationType.externalLink => DiscChat.moderationLinkBlocked,
      ChatMessageViolationType.bankDetails => DiscChat.moderationBankBlocked,
      ChatMessageViolationType.externalContact =>
        DiscChat.moderationExternalContactBlocked,
      ChatMessageViolationType.physicalAddress =>
        DiscChat.moderationAddressBlocked,
      ChatMessageViolationType.contactSolicitation =>
        DiscChat.moderationSolicitationBlocked,
      ChatMessageViolationType.insult => DiscChat.moderationInsultBlocked,
      ChatMessageViolationType.sexualContent =>
        DiscChat.moderationSexualBlocked,
    };
  }
}

/// Modération des messages (style Leboncoin : pas de coordonnées hors plateforme).
abstract final class ChatMessageModerator {
  ChatMessageModerator._();

  static const _crossMessageWindow = 6;
  static const _minPhoneChunkDigits = 6;

  static final _emailPattern = RegExp(
    r'\b[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}\b',
    caseSensitive: false,
  );

  static final _partialEmailPattern = RegExp(
    r'@[A-Za-z0-9.\-]+|'
    r'\b[A-Za-z0-9._%+\-]{2,}@[A-Za-z0-9.\-]*\b|'
    r'\b[A-Za-z0-9._%+\-]+\s*@\s*[A-Za-z0-9.\-]+\b',
    caseSensitive: false,
  );

  static final _emailObfuscationPattern = RegExp(
    r'\b(?:at|arobase|chez)\b.{0,24}\b(?:gmail|yahoo|hotmail|outlook|icloud|live|protonmail)\b|'
    r'\b(?:gmail|yahoo|hotmail|outlook|icloud|live|protonmail)\s*(?:dot|point)\s*(?:com|fr|net|org)\b',
    caseSensitive: false,
  );

  static final _urlPattern = RegExp(
    r'(https?:\/\/|www\.)[^\s]+|'
    r'\b[a-z0-9][a-z0-9\-]*\.(com|fr|net|org|io|co|app|link|me|be|eu|info|biz)\b',
    caseSensitive: false,
  );

  static final _ibanPattern = RegExp(
    r'\bFR\s?\d{2}(?:\s?\d{4}){2,7}\b|\biban\b',
    caseSensitive: false,
  );

  static final _ribKeywordPattern = RegExp(
    r'\b(rib|virement|iban|bic|swift)\b',
    caseSensitive: false,
  );

  static final _longDigitSequence = RegExp(r'\d[\d\s.\-]{10,}\d');

  static final _externalContactPattern = RegExp(
    r'\b(whatsapp|whats\s?app|watsapp|snap(chat)?|instagram|insta(gram)?|'
    r'telegram|tiktok|facebook|messenger|discord|signal)\b',
    caseSensitive: false,
  );

  static final _frenchPostalCode = RegExp(
    r'\b(?:0[1-9]|[1-8]\d|9[0-8])\d{3}\b',
  );

  static final _addressKeywordPattern = RegExp(
    r'\b(?:rue|avenue|av\.?|boulevard|bd\.?|chemin|impasse|all[ée]e|place|route|'
    r'quai|cours|square|passage|lotissement|r[ée]sidence|villa|domaine)\b',
    caseSensitive: false,
  );

  static final _streetNumberPattern = RegExp(
    r'\b\d{1,4}\s*,?\s*(?:rue|avenue|av\.?|boulevard|bd\.?|chemin|impasse|all[ée]e|place|route)\b',
    caseSensitive: false,
  );

  static final _contactSolicitationPattern = RegExp(
    r'\b(?:donne[rz]?|donne|envo(?:ye|i)(?:r|e)?|partage[rz]?|communique[rz]?|passe[rz]?|'
    r'envoi(?:e|ez)?|transmet(?:tre|tez)?|écri(?:s|vez)|ecri(?:s|vez))'
    r'(?:\s*[\-–—]?\s*moi)?\s+'
    r'(?:ton|ta|votre|tes|vos|le|la|les|un|une)?\s*'
    r'(?:num[eé]ro|n°|tel(?:[eé]phone)?|mobile|portable|mail|e-?mail|courriel|adresse|'
    r'coordonn[eé]es|rib|iban|whatsapp|instagram|snap)\b',
    caseSensitive: false,
  );

  static final _contactSolicitationPossessivePattern = RegExp(
    r'\b(?:ton|ta|votre|vos)\s+'
    r'(?:num[eé]ro|n°|tel(?:[eé]phone)?|mobile|portable|mail|e-?mail|courriel|adresse|'
    r'coordonn[eé]es|rib|iban)\b',
    caseSensitive: false,
  );

  static final _contactSolicitationAltPattern = RegExp(
    r'\b(?:quel(?:le)?s?\s+(?:est|sont)\s+(?:ton|ta|votre)|'
    r'tu\s+peux\s+(?:me\s+)?(?:donner|envoyer|passer)|'
    r'peux[- ]tu\s+(?:me\s+)?(?:donner|envoyer|passer))\s+'
    r'(?:ton|ta|votre)?\s*(?:num[eé]ro|tel|mail|adresse|coordonn[eé]es)\b',
    caseSensitive: false,
  );

  static final _contactSolicitationNounPattern = RegExp(
    r'\b(?:num[eé]ro|tel(?:[eé]phone)?|mail|e-?mail|adresse)\s+(?:de\s+)?(?:contact|perso(?:nnel)?|priv[ée])\b',
    caseSensitive: false,
  );

  static ChatMessageModerationResult analyze(
    String text, {
    ChatMessageModerationContext context = const ChatMessageModerationContext(),
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return ChatMessageModerationResult.none;

    final violations = <ChatMessageViolationType>[];
    final recent = _normalizedRecent(context.recentOutgoingMessages);
    final window = _messageWindow(recent, trimmed);

    void add(ChatMessageViolationType type) {
      if (!violations.contains(type)) violations.add(type);
    }

    if (_containsPhoneNumber(trimmed) ||
        _containsSplitPhone(window) ||
        _isSuspiciousPhoneChunk(trimmed)) {
      add(ChatMessageViolationType.phoneNumber);
    }

    if (_containsEmail(trimmed) ||
        _containsSplitEmail(window) ||
        _emailObfuscationPattern.hasMatch(trimmed)) {
      add(ChatMessageViolationType.email);
    }

    if (_urlPattern.hasMatch(trimmed)) {
      add(ChatMessageViolationType.externalLink);
    }

    if (_ibanPattern.hasMatch(trimmed) ||
        (_ribKeywordPattern.hasMatch(trimmed) &&
            _longDigitSequence.hasMatch(trimmed))) {
      add(ChatMessageViolationType.bankDetails);
    }

    if (_externalContactPattern.hasMatch(trimmed)) {
      add(ChatMessageViolationType.externalContact);
    }

    if (_containsPhysicalAddress(trimmed) || _containsSplitAddress(window)) {
      add(ChatMessageViolationType.physicalAddress);
    }

    if (_containsContactSolicitation(trimmed)) {
      add(ChatMessageViolationType.contactSolicitation);
    }

    if (_containsInsult(trimmed) || _containsSplitInsult(window)) {
      add(ChatMessageViolationType.insult);
    }

    if (_containsSexualContent(trimmed) || _containsSplitSexualContent(window)) {
      add(ChatMessageViolationType.sexualContent);
    }

    return ChatMessageModerationResult(violations: violations);
  }

  /// Masque le contenu sensible à l'affichage (bulles reçues / anciennes).
  static String sanitizeForDisplay(String text) {
    if (text.trim().isEmpty) return text;

    var out = text;
    out = out.replaceAllMapped(_emailPattern, (_) => '•••@•••.••');
    out = out.replaceAllMapped(_partialEmailPattern, (_) => '•••@•••');
    out = out.replaceAllMapped(_urlPattern, (_) => 'lien masqué');
    out = _maskPhoneLikeSequences(out);
    out = ChatInappropriateContent.mask(out);
    return out;
  }

  static bool _containsInsult(String text) =>
      ChatInappropriateContent.containsInsult(text);

  static bool _containsSexualContent(String text) =>
      ChatInappropriateContent.containsSexualContent(text);

  static bool _containsSplitInsult(List<String> window) {
    if (window.length <= 1) return false;
    return ChatInappropriateContent.containsInsult(window.join('')) ||
        ChatInappropriateContent.containsInsult(window.join(' '));
  }

  static bool _containsSplitSexualContent(List<String> window) {
    if (window.length <= 1) return false;
    return ChatInappropriateContent.containsSexualContent(window.join('')) ||
        ChatInappropriateContent.containsSexualContent(window.join(' '));
  }

  static List<String> _normalizedRecent(List<String> messages) {
    return messages
        .map((m) => m.trim())
        .where((m) => m.isNotEmpty)
        .toList();
  }

  static List<String> _messageWindow(List<String> recent, String current) {
    final tail = recent.length > _crossMessageWindow - 1
        ? recent.sublist(recent.length - (_crossMessageWindow - 1))
        : recent;
    return [...tail, current];
  }

  static bool _containsEmail(String text) {
    if (_emailPattern.hasMatch(text)) return true;
    if (_partialEmailPattern.hasMatch(text)) return true;
    if (text.contains('@')) return true;
    return false;
  }

  static bool _containsSplitEmail(List<String> window) {
    final joined = window.join('');
    final spaced = window.join(' ');
    return _emailPattern.hasMatch(joined) ||
        _emailPattern.hasMatch(spaced) ||
        _partialEmailPattern.hasMatch(joined) ||
        joined.contains('@');
  }

  static bool _containsPhysicalAddress(String text) {
    if (_frenchPostalCode.hasMatch(text) && _isMostlyNumericOrAddress(text)) {
      return true;
    }
    if (_streetNumberPattern.hasMatch(text)) return true;
    if (_addressKeywordPattern.hasMatch(text) &&
        RegExp(r'\d').hasMatch(text)) {
      return true;
    }
    return false;
  }

  static bool _containsSplitAddress(List<String> window) {
    final blob = window.join(' ');
    if (!_addressKeywordPattern.hasMatch(blob) &&
        !_frenchPostalCode.hasMatch(blob)) {
      return false;
    }
    return _containsPhysicalAddress(blob);
  }

  static bool _isMostlyNumericOrAddress(String text) {
    final trimmed = text.trim();
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 5 && _frenchPostalCode.hasMatch(trimmed)) return true;
    return _addressKeywordPattern.hasMatch(trimmed);
  }

  static bool _containsContactSolicitation(String text) {
    return _contactSolicitationPattern.hasMatch(text) ||
        _contactSolicitationAltPattern.hasMatch(text) ||
        _contactSolicitationNounPattern.hasMatch(text) ||
        _contactSolicitationPossessivePattern.hasMatch(text);
  }

  static bool _containsPhoneNumber(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length >= 10) {
      if (RegExp(r'^0[1-9]\d{8}$').hasMatch(digitsOnly)) return true;
      if (RegExp(r'^33[1-9]\d{8}$').hasMatch(digitsOnly)) return true;
      if (digitsOnly.length >= 10 && digitsOnly.length <= 15) {
        final spaced = RegExp(
          r'(?:\+33|0033|0)\s*[1-9](?:[\s.\-]?\d{2}){4}',
          caseSensitive: false,
        );
        if (spaced.hasMatch(text)) return true;
      }
    }

    final generic = RegExp(r'(?:\+?\d[\d\s.\-]{7,}\d)');
    if (generic.hasMatch(text)) {
      final chunk = generic
          .allMatches(text)
          .map((m) => m.group(0)!.replaceAll(RegExp(r'\D'), ''))
          .where((d) => d.length >= 8);
      if (chunk.isNotEmpty) return true;
    }
    return false;
  }

  static bool _containsSplitPhone(List<String> window) {
    final combined = window.map((m) => m.replaceAll(RegExp(r'\D'), '')).join();
    if (combined.length < 10) return false;
    return _isFrenchPhoneDigits(combined) || _isInternationalPhoneDigits(combined);
  }

  static bool _isSuspiciousPhoneChunk(String text) {
    if (_addressKeywordPattern.hasMatch(text) ||
        _streetNumberPattern.hasMatch(text)) {
      return false;
    }

    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return false;

    if (digits.length >= _minPhoneChunkDigits) return true;

    if (digits.length >= 4 && _isMostlyNumericMessage(text)) {
      if (RegExp(r'^0[67]').hasMatch(digits)) return true;
      if (RegExp(r'^\+?33[67]').hasMatch(digits.replaceFirst('33', ''))) {
        return true;
      }
    }

    return false;
  }

  static bool _isMostlyNumericMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    final withoutDigits = trimmed.replaceAll(RegExp(r'[\d\s.\-+()/]'), '');
    return withoutDigits.length <= 2;
  }

  static bool _isFrenchPhoneDigits(String digits) {
    if (RegExp(r'^0[1-9]\d{8,}$').hasMatch(digits)) return true;
    if (RegExp(r'^33[1-9]\d{8,}$').hasMatch(digits)) return true;
    return false;
  }

  static bool _isInternationalPhoneDigits(String digits) {
    return digits.length >= 10 && digits.length <= 15;
  }

  static String _maskPhoneLikeSequences(String text) {
    return text.replaceAllMapped(
      RegExp(r'(?:\+33|0033|0)\s*[1-9](?:[\s.\-]?\d{2}){4}|\d{6,}'),
      (_) => '•• •• •• •• ••',
    );
  }
}

import 'package:madbeauty/core/constants/app_strings.dart';

/// Type de contenu interdit dans la messagerie (sécurité plateforme).
enum ChatMessageViolationType {
  phoneNumber,
  email,
  externalLink,
  bankDetails,
  externalContact,
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
    };
  }
}

/// Modération des messages (style Leboncoin : pas de coordonnées hors plateforme).
abstract final class ChatMessageModerator {
  ChatMessageModerator._();

  static final _emailPattern = RegExp(
    r'\b[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}\b',
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

  static ChatMessageModerationResult analyze(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return ChatMessageModerationResult.none;

    final violations = <ChatMessageViolationType>[];

    void add(ChatMessageViolationType type) {
      if (!violations.contains(type)) violations.add(type);
    }

    if (_containsPhoneNumber(trimmed)) add(ChatMessageViolationType.phoneNumber);
    if (_emailPattern.hasMatch(trimmed)) add(ChatMessageViolationType.email);
    if (_urlPattern.hasMatch(trimmed)) add(ChatMessageViolationType.externalLink);
    if (_ibanPattern.hasMatch(trimmed) ||
        (_ribKeywordPattern.hasMatch(trimmed) &&
            _longDigitSequence.hasMatch(trimmed))) {
      add(ChatMessageViolationType.bankDetails);
    }
    if (_externalContactPattern.hasMatch(trimmed)) {
      add(ChatMessageViolationType.externalContact);
    }

    return ChatMessageModerationResult(violations: violations);
  }

  /// Masque le contenu sensible à l'affichage (bulles reçues / anciennes).
  static String sanitizeForDisplay(String text) {
    if (text.trim().isEmpty) return text;

    var out = text;
    out = out.replaceAllMapped(_emailPattern, (_) => '•••@•••.••');
    out = out.replaceAllMapped(
      _urlPattern,
      (_) => 'lien masqué',
    );
    out = _maskPhoneLikeSequences(out);
    return out;
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

    final generic = RegExp(
      r'(?:\+?\d[\d\s.\-]{7,}\d)',
    );
    if (generic.hasMatch(text)) {
      final chunk = generic
          .allMatches(text)
          .map((m) => m.group(0)!.replaceAll(RegExp(r'\D'), ''))
          .where((d) => d.length >= 8);
      if (chunk.isNotEmpty) return true;
    }
    return false;
  }

  static String _maskPhoneLikeSequences(String text) {
    return text.replaceAllMapped(
      RegExp(r'(?:\+33|0033|0)\s*[1-9](?:[\s.\-]?\d{2}){4}|\d{10,}'),
      (_) => '•• •• •• •• ••',
    );
  }
}

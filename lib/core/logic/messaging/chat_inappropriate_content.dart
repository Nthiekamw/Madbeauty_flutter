/// Détection d'insultes et de contenu sexuel explicite (messagerie).
abstract final class ChatInappropriateContent {
  ChatInappropriateContent._();

  static final _insultTerms = <String>[
    'connard',
    'connasse',
    'salope',
    'salopard',
    'pute',
    'putain',
    'encule',
    'enculer',
    'enfoire',
    'enfoiree',
    'batard',
    'merde',
    'nique',
    'niquer',
    'ntm',
    'fdp',
    'filsdepute',
    'trouduc',
    'trouducul',
    'couille',
    'couilles',
    'grognasse',
    'debile',
    'abruti',
    'abrutie',
    'imbecile',
    'cretin',
    'salaud',
    'salecon',
    'salepute',
    'fermetagueule',
    'tagueule',
    'cassetoi',
    'vatefaire',
    'vatefairefoutre',
    'foutre',
  ];

  static final _sexualTerms = <String>[
    'porn',
    'porno',
    'pornographique',
    'nude',
    'nudes',
    'apoil',
    'plancul',
    'planq',
    'branlette',
    'branler',
    'ejacul',
    'orgasme',
    'penis',
    'vagin',
    'chatte',
    'tetons',
    'seinsnus',
  ];

  static final _insultPatterns = <RegExp>[
    RegExp(
      r'\b(?:va\s+te\s+faire|va\s+te\s+foutre|ferme\s+ta\s+gueule|'
      r'ta\s+gueule|casse\s+toi|sale\s+(?:pute|connard|salope))\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\bnique\s+(?:ta|ton|tes|votre)\s+(?:mere|mère|maman)\b',
      caseSensitive: false,
    ),
    RegExp(r'\bfils\s+de\s+pute\b', caseSensitive: false),
    RegExp(r'\b(?:fdp|ntm|pd)\b', caseSensitive: false),
  ];

  static final _sexualPatterns = <RegExp>[
    RegExp(
      r'\b(?:photo|photos|vid[ée]o|snap|selfie)s?\s+'
      r'(?:intime|hot|coquine?|nue?s?|chaude?s?|sexuelle?s?)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(?:envie|proposition|offre|demande)\s+(?:de\s+)?(?:sexe|cul|plan\s*cul)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(?:coucher|baiser|niquer|sucer|enculer)\s+(?:avec|ensemble|toi|moi)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(?:on\s+)?(?:baise|baiser|nique|niquer|suce|sucer)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(?:sexy|coquin(?:e)?|chaud(?:e)?)\s+(?:ce\s+soir|avec\s+moi|photo|snap)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(?:montre|montrez|envo(?:ie|ye)|envoie)\s+(?:ton|ta|tes|votre|vos)\s+'
      r'(?:corps|poitrine|cul|fesse|chatte|bite|nude|nudes)\b',
      caseSensitive: false,
    ),
    RegExp(r'\b(?:à|a)\s+poil\b', caseSensitive: false),
    RegExp(r'\bplan\s*(?:cul|q)\b', caseSensitive: false),
  ];

  static late final List<RegExp> _looseInsultRegexes = [
    for (final term in _insultTerms) _looseTermPattern(term),
  ];

  static late final List<RegExp> _looseSexualRegexes = [
    for (final term in _sexualTerms) _looseTermPattern(term),
  ];

  static bool containsInsult(String text) =>
      _matches(text, _insultPatterns, _looseInsultRegexes);

  static bool containsSexualContent(String text) =>
      _matches(text, _sexualPatterns, _looseSexualRegexes);

  static String mask(String text) {
    var out = text;
    for (final pattern in [
      ..._insultPatterns,
      ..._sexualPatterns,
      ..._looseInsultRegexes,
      ..._looseSexualRegexes,
    ]) {
      out = out.replaceAllMapped(pattern, (_) => '•••');
    }
    return out;
  }

  static bool _matches(
    String text,
    List<RegExp> patterns,
    List<RegExp> loosePatterns,
  ) {
    final normalized = _normalize(text);
    final compact = _compact(normalized);

    for (final pattern in patterns) {
      if (pattern.hasMatch(normalized) || pattern.hasMatch(text)) return true;
    }

    for (final pattern in loosePatterns) {
      if (pattern.hasMatch(normalized) || pattern.hasMatch(text)) return true;
    }

    for (final term in [..._insultTerms, ..._sexualTerms]) {
      if (term.length >= 5 && compact.contains(term)) return true;
    }

    return false;
  }

  static RegExp _looseTermPattern(String term) {
    final letters = term.split('').map(RegExp.escape).join(r'[\W_]*');
    return RegExp('\\b$letters\\b', caseSensitive: false);
  }

  static String _normalize(String text) {
    var out = text.toLowerCase();
    out = _stripAccents(out);
    out = out
        .replaceAll('@', 'a')
        .replaceAll('0', 'o')
        .replaceAll('1', 'i')
        .replaceAll('3', 'e')
        .replaceAll('4', 'a')
        .replaceAll('5', 's')
        .replaceAll(r'$', 's');
    return out;
  }

  static String _compact(String text) =>
      text.replaceAll(RegExp(r'[^a-z]'), '');

  static String _stripAccents(String value) {
    const map = {
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'á': 'a',
      'ã': 'a',
      'å': 'a',
      'ç': 'c',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'î': 'i',
      'ï': 'i',
      'í': 'i',
      'ì': 'i',
      'ô': 'o',
      'ö': 'o',
      'ó': 'o',
      'ò': 'o',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ú': 'u',
      'ÿ': 'y',
      'œ': 'oe',
      'æ': 'ae',
    };
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(map[char] ?? char);
    }
    return buffer.toString();
  }
}

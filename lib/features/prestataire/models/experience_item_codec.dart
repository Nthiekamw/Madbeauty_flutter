/// Encodage des entrées personnalisées (confort / conditions) dans les tableaux SQL.
abstract final class ExperienceItemCodec {
  ExperienceItemCodec._();

  static const customPrefix = 'custom:';

  static bool isCustom(String id) => id.startsWith(customPrefix);

  static String encodeCustom(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return '';
    return '$customPrefix$trimmed';
  }

  static String decodeCustomLabel(String id) {
    if (!isCustom(id)) return id;
    return id.substring(customPrefix.length).trim();
  }
}


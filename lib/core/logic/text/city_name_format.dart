/// Normalise un nom de ville pour l'affichage et la persistance.
///
/// Ex. `paris` → `Paris`, `SAINT-ÉTIENNE` → `Saint-Étienne`,
/// `l'isle-d'abeau` → `L'Isle-D'Abeau`.
String formatCityName(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';

  return trimmed
      .split(RegExp(r'\s+'))
      .map(
        (word) => word.split('-').map(_capitalizeCityToken).join('-'),
      )
      .join(' ');
}

String _capitalizeCityToken(String token) {
  if (token.isEmpty) return token;

  final lower = token.toLowerCase();
  final buffer = StringBuffer();
  var upperNext = true;

  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    if (upperNext && _isCityLetter(char)) {
      buffer.write(char.toUpperCase());
      upperNext = false;
    } else {
      buffer.write(char);
      if (char == "'") upperNext = true;
    }
  }

  return buffer.toString();
}

bool _isCityLetter(String char) {
  if (char.isEmpty) return false;
  final code = char.codeUnitAt(0);
  return (code >= 0x41 && code <= 0x5A) ||
      (code >= 0x61 && code <= 0x7A) ||
      code >= 0xC0;
}

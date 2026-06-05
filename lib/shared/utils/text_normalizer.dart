String normalizeSingleLineText(String? raw) {
  if (raw == null) return '';
  return raw
      .replaceAll(RegExp(r'[\s\u200B\u200C\u200D\uFEFF]+'), ' ')
      .trim();
}


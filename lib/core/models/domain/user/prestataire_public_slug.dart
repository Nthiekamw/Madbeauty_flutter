/// Helpers pour les liens courts prestataire (`/@slug`).
abstract final class PrestatairePublicSlug {
  PrestatairePublicSlug._();

  static final _slugPattern = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

  /// Normalise une ref URL (`@Vichy`, ` Vichy ` → `vichy`).
  static String? normalize(String? raw) {
    var v = raw?.trim().toLowerCase() ?? '';
    if (v.startsWith('@')) v = v.substring(1).trim();
    if (v.isEmpty) return null;
    if (!_slugPattern.hasMatch(v)) return null;
    if (v.length < 2 || v.length > 48) return null;
    return v;
  }

  /// Affiche le handle public (`@vichy`).
  static String handle(String slug) => '@${slug.trim().toLowerCase()}';
}

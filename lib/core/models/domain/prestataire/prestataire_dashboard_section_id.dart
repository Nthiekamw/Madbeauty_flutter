/// Identifiants des blocs réordonnables du dashboard prestataire.
enum PrestataireDashboardSectionId {
  hero,
  analytics,
  stats,
  pending,
  today,
  week;

  String get storageKey => name;

  static PrestataireDashboardSectionId? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final id in PrestataireDashboardSectionId.values) {
      if (id.name == raw || id.storageKey == raw) return id;
    }
    return null;
  }
}

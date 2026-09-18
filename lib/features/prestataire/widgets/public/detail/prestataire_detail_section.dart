enum PrestataireDetailSection {
  services,
  boutique,
  offres,
  gallery,
  about,
  reviews;

  static PrestataireDetailSection? tryParse(String? raw) {
    final value = raw?.trim().toLowerCase();
    if (value == null || value.isEmpty) return null;
    for (final section in values) {
      if (section.name == value) return section;
    }
    return null;
  }
}

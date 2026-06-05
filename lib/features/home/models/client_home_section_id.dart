/// Sections réordonnables de l'accueil client.
enum ClientHomeSectionId {
  nextAppointment('next_appointment'),
  inspiration('inspiration'),
  feed('feed'),
  nearby('nearby'),
  topRated('top_rated');

  const ClientHomeSectionId(this.storageKey);

  final String storageKey;

  static ClientHomeSectionId? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final id in ClientHomeSectionId.values) {
      if (id.storageKey == raw) return id;
    }
    return null;
  }
}

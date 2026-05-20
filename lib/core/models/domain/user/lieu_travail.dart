/// Où le prestataire exerce (spec `workLocation`).
enum LieuTravail {
  home('home'),
  client('client'),
  both('both');

  const LieuTravail(this.value);

  final String value;

  static LieuTravail? fromValue(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    for (final v in LieuTravail.values) {
      if (v.value == raw.trim()) return v;
    }
    return null;
  }
}

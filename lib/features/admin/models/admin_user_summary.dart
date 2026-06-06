class AdminUserSummary {
  const AdminUserSummary({
    required this.userId,
    required this.email,
    this.prenom,
    this.nom,
    required this.isBanned,
    this.bannedAt,
    this.banReason,
    required this.roles,
  });

  final String userId;
  final String email;
  final String? prenom;
  final String? nom;
  final bool isBanned;
  final DateTime? bannedAt;
  final String? banReason;
  final List<String> roles;

  String get displayName {
    final full = '${prenom ?? ''} ${nom ?? ''}'.trim();
    return full.isEmpty ? email : full;
  }
}

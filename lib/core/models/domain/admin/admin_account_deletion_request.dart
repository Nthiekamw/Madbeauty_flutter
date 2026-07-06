/// Demande de suppression de compte en attente (back-office admin).
class AdminAccountDeletionRequest {
  const AdminAccountDeletionRequest({
    required this.userId,
    required this.email,
    this.prenom,
    this.nom,
    required this.requestedAt,
    required this.roles,
  });

  final String userId;
  final String email;
  final String? prenom;
  final String? nom;
  final DateTime? requestedAt;
  final List<String> roles;

  String get displayName {
    final parts = [prenom, nom]
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isNotEmpty) return parts.join(' ');
    if (email.trim().isNotEmpty) return email.trim();
    return userId;
  }
}

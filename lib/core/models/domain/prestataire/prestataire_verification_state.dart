/// État de la demande de badge vérifié (profil prestataire).
class PrestataireVerificationState {
  const PrestataireVerificationState({
    required this.found,
    required this.isVerified,
    this.requestedAt,
    this.verifiedAt,
    this.adminNote,
    required this.canRequest,
  });

  final bool found;
  final bool isVerified;
  final DateTime? requestedAt;
  final DateTime? verifiedAt;
  final String? adminNote;
  final bool canRequest;

  /// Demande envoyée, en attente de revue admin.
  bool get isPending => !isVerified && requestedAt != null;

  bool get wasRevoked =>
      !isVerified &&
      requestedAt == null &&
      (adminNote?.trim().isNotEmpty ?? false);

  factory PrestataireVerificationState.empty() =>
      const PrestataireVerificationState(
        found: false,
        isVerified: false,
        canRequest: false,
      );

  factory PrestataireVerificationState.fromJson(Map<String, dynamic> json) {
    if (json['found'] != true) {
      return PrestataireVerificationState.empty();
    }
    final isVerified = _asBool(json['is_verified']) ?? false;
    final requestedAt = _parseDate(json['verification_requested_at']);
    final verifiedAt = _parseDate(json['verified_at']);
    final adminNote = (json['verification_note'] as String?)?.trim();

    // Source de vérité côté app : jamais de CTA si déjà en attente / vérifié.
    final canRequest = !isVerified && requestedAt == null;

    return PrestataireVerificationState(
      found: true,
      isVerified: isVerified,
      requestedAt: requestedAt,
      verifiedAt: verifiedAt,
      adminNote: adminNote,
      canRequest: canRequest,
    );
  }

  static bool? _asBool(Object? raw) {
    if (raw is bool) return raw;
    if (raw is String) {
      final v = raw.trim().toLowerCase();
      if (v == 'true' || v == 't' || v == '1') return true;
      if (v == 'false' || v == 'f' || v == '0') return false;
    }
    if (raw is num) return raw != 0;
    return null;
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is String && raw.trim().isNotEmpty) {
      return DateTime.tryParse(raw.trim());
    }
    return null;
  }
}

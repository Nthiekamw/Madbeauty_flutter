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

  bool get isPending => !isVerified && requestedAt != null;

  bool get wasRevoked =>
      !isVerified && !isPending && (adminNote?.trim().isNotEmpty ?? false);

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
    return PrestataireVerificationState(
      found: true,
      isVerified: json['is_verified'] as bool? ?? false,
      requestedAt: _parseDate(json['verification_requested_at']),
      verifiedAt: _parseDate(json['verified_at']),
      adminNote: (json['verification_note'] as String?)?.trim(),
      canRequest: json['can_request'] as bool? ?? false,
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }
}

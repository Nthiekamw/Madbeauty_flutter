class AdminVerificationRequest {
  const AdminVerificationRequest({
    required this.prestataireId,
    required this.userId,
    required this.displayName,
    required this.nomSalon,
    required this.ville,
    required this.isVerified,
    this.verifiedAt,
    this.verificationRequestedAt,
  });

  final String prestataireId;
  final String userId;
  final String displayName;
  final String? nomSalon;
  final String? ville;
  final bool isVerified;
  final DateTime? verifiedAt;
  final DateTime? verificationRequestedAt;
}


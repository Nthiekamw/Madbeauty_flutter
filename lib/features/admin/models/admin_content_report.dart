class AdminContentReport {
  const AdminContentReport({
    required this.id,
    required this.reporterUserId,
    this.reporterEmail,
    this.reporterDisplayName,
    required this.targetType,
    required this.targetId,
    this.targetLabel,
    required this.reason,
    this.details,
    required this.createdAt,
    this.reviewedAt,
  });

  final String id;
  final String reporterUserId;
  final String? reporterEmail;
  final String? reporterDisplayName;
  final String targetType;
  final String targetId;
  final String? targetLabel;
  final String reason;
  final String? details;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  bool get isReviewed => reviewedAt != null;

  String get reporterLabel {
    final name = reporterDisplayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = reporterEmail?.trim();
    if (email != null && email.isNotEmpty) return email;
    return reporterUserId;
  }

  String get targetTypeLabel => switch (targetType) {
    'prestataire_profile' => 'Profil prestataire',
    'conversation' => 'Conversation',
    'message' => 'Message',
    _ => targetType,
  };

  String get displayTarget => targetLabel?.trim().isNotEmpty == true
      ? targetLabel!.trim()
      : targetId;
}

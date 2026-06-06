class AdminAuditEntry {
  const AdminAuditEntry({
    required this.id,
    required this.actorUserId,
    this.actorDisplayName,
    required this.action,
    required this.entityType,
    required this.entityId,
    this.metadata,
    required this.createdAt,
  });

  final String id;
  final String actorUserId;
  final String? actorDisplayName;
  final String action;
  final String entityType;
  final String entityId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
}

class AdminVerificationEvent {
  const AdminVerificationEvent({
    required this.id,
    required this.prestataireId,
    this.nomSalon,
    required this.actorUserId,
    this.actorDisplayName,
    required this.action,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String prestataireId;
  final String? nomSalon;
  final String actorUserId;
  final String? actorDisplayName;
  final String action;
  final String? note;
  final DateTime createdAt;
}

import '../../core/models/domain/booking/client_reservation_summary.dart';

/// Types d'actions rejouées à la reconnexion.
enum OfflineActionType {
  bookingCreate,
  bookingCancel,
  bookingConfirm,
  bookingReject,
  bookingMarkDone,
  /// Réservé (messagerie pas encore branchée côté API).
  messageSend,
}

/// Action locale en attente de synchronisation Supabase.
class PendingOfflineAction {
  PendingOfflineAction({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  static const String localIdPrefix = 'local:';

  final String id;
  final OfflineActionType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;

  bool get isLocalBookingId {
    final bookingId = payload['reservationId'] as String?;
    return bookingId != null && bookingId.startsWith(localIdPrefix);
  }

  static String newActionId() =>
      'act_${DateTime.now().microsecondsSinceEpoch}';

  static String newLocalReservationId() =>
      '$localIdPrefix${DateTime.now().microsecondsSinceEpoch}';

  factory PendingOfflineAction.create({
    required OfflineActionType type,
    required Map<String, dynamic> payload,
    String? id,
  }) {
    return PendingOfflineAction(
      id: id ?? newActionId(),
      type: type,
      payload: payload,
      createdAt: DateTime.now(),
    );
  }

  PendingOfflineAction copyWith({
    int? retryCount,
    String? lastError,
    bool clearError = false,
  }) {
    return PendingOfflineAction(
      id: id,
      type: type,
      payload: payload,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
    'retryCount': retryCount,
    if (lastError != null) 'lastError': lastError,
  };

  static PendingOfflineAction? fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String?;
    OfflineActionType? type;
    for (final candidate in OfflineActionType.values) {
      if (candidate.name == typeName) {
        type = candidate;
        break;
      }
    }
    if (type == null) return null;

    final payload = json['payload'];
    if (payload is! Map) return null;

    final createdRaw = json['createdAt'] as String?;
    final createdAt = createdRaw != null
        ? DateTime.tryParse(createdRaw)
        : null;
    if (createdAt == null) return null;

    return PendingOfflineAction(
      id: json['id'] as String? ?? newActionId(),
      type: type,
      payload: Map<String, dynamic>.from(payload),
      createdAt: createdAt,
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      lastError: json['lastError'] as String?,
    );
  }

  /// Réservation client affichée localement avant synchro.
  ClientReservationSummary? toPendingClientSummary() {
    if (type != OfflineActionType.bookingCreate) return null;

    final localId = payload['localReservationId'] as String?;
    final dateRaw = payload['dateHeure'] as String?;
    if (localId == null || dateRaw == null) return null;

    final dateHeure = DateTime.tryParse(dateRaw);
    if (dateHeure == null) return null;

    return ClientReservationSummary(
      id: localId,
      dateHeure: dateHeure,
      statut: 'sync_pending',
      serviceName: payload['serviceName'] as String?,
      prestataireName: payload['prestataireName'] as String?,
      prestataireAvatarUrl: payload['prestataireAvatarUrl'] as String?,
    );
  }
}


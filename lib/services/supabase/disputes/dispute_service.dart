import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';

enum DisputeReason {
  noShow('no_show'),
  deposit('deposit'),
  quality('quality'),
  refund('refund'),
  other('other');

  const DisputeReason(this.value);
  final String value;

  static DisputeReason? tryParse(String? raw) {
    final s = raw?.trim();
    if (s == null || s.isEmpty) return null;
    for (final r in DisputeReason.values) {
      if (r.value == s) return r;
    }
    return null;
  }
}

enum DisputeStatus {
  open('open'),
  underReview('under_review'),
  resolvedFavorClient('resolved_favor_client'),
  resolvedFavorPresta('resolved_favor_presta'),
  closed('closed');

  const DisputeStatus(this.value);
  final String value;

  bool get isOpen => this == open || this == underReview;
  bool get isTerminal =>
      this == resolvedFavorClient ||
      this == resolvedFavorPresta ||
      this == closed;

  static DisputeStatus parse(String? raw) {
    final s = raw?.trim() ?? '';
    for (final st in DisputeStatus.values) {
      if (st.value == s) return st;
    }
    return DisputeStatus.open;
  }
}

enum DisputeSenderRole {
  client('client'),
  prestataire('prestataire'),
  admin('admin');

  const DisputeSenderRole(this.value);
  final String value;

  static DisputeSenderRole parse(String? raw) {
    final s = raw?.trim() ?? '';
    for (final r in DisputeSenderRole.values) {
      if (r.value == s) return r;
    }
    return DisputeSenderRole.client;
  }
}

class BookingDispute {
  const BookingDispute({
    required this.id,
    required this.reservationId,
    required this.clientId,
    required this.prestataireId,
    required this.openedBy,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.amountCents,
    this.summary,
    this.adminNotes,
    this.resolution,
    this.resolvedAt,
    this.resolvedBy,
  });

  final String id;
  final String reservationId;
  final String clientId;
  final String prestataireId;
  final String openedBy;
  final String reason;
  final String status;
  final int? amountCents;
  final String? summary;
  final String? adminNotes;
  final String? resolution;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  DisputeStatus get statusEnum => DisputeStatus.parse(status);
  bool get canMessage => statusEnum.isOpen;

  factory BookingDispute.fromRow(Map<String, dynamic> row) {
    return BookingDispute(
      id: row['id'] as String? ?? '',
      reservationId: row['reservation_id'] as String? ?? '',
      clientId: row['client_id'] as String? ?? '',
      prestataireId: row['prestataire_id'] as String? ?? '',
      openedBy: row['opened_by'] as String? ?? 'client',
      reason: row['reason'] as String? ?? 'other',
      status: row['status'] as String? ?? 'open',
      amountCents: (row['amount_cents'] as num?)?.toInt(),
      summary: row['summary'] as String?,
      adminNotes: row['admin_notes'] as String?,
      resolution: row['resolution'] as String?,
      createdAt: _parseDate(row['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: _parseDate(row['updated_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      resolvedAt: _parseDate(row['resolved_at']),
      resolvedBy: row['resolved_by'] as String?,
    );
  }
}

class DisputeMessage {
  const DisputeMessage({
    required this.id,
    required this.disputeId,
    required this.senderUserId,
    required this.senderRole,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String disputeId;
  final String senderUserId;
  final String senderRole;
  final String body;
  final DateTime createdAt;

  factory DisputeMessage.fromRow(Map<String, dynamic> row) {
    return DisputeMessage(
      id: row['id'] as String? ?? '',
      disputeId: row['dispute_id'] as String? ?? '',
      senderUserId: row['sender_user_id'] as String? ?? '',
      senderRole: row['sender_role'] as String? ?? 'client',
      body: row['body'] as String? ?? '',
      createdAt: _parseDate(row['created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

DateTime? _parseDate(Object? raw) {
  if (raw is DateTime) return raw;
  if (raw is String) return DateTime.tryParse(raw);
  return null;
}

class DisputeService {
  DisputeService(this._client);

  final SupabaseClient _client;

  Future<BookingDispute> open({
    required String reservationId,
    required DisputeReason reason,
    String? summary,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'dispute.open',
        action: () async {
          final raw = await _client.rpc(
            'open_booking_dispute',
            params: {
              'p_reservation_id': reservationId,
              'p_reason': reason.value,
              'p_summary': summary?.trim().isNotEmpty == true
                  ? summary!.trim()
                  : null,
            },
          );
          final map = Map<String, dynamic>.from(raw as Map);
          return BookingDispute.fromRow(map);
        },
      );

  Future<List<BookingDispute>> listMine({int limit = 50}) =>
      SupabaseErrorHandler.run(
        operation: 'dispute.listMine',
        action: () async {
          final rows = await _client
              .from('booking_disputes')
              .select()
              .order('created_at', ascending: false)
              .limit(limit.clamp(1, 100));
          return _decodeDisputes(rows);
        },
      );

  Future<BookingDispute?> getById(String disputeId) =>
      SupabaseErrorHandler.run(
        operation: 'dispute.getById',
        action: () async {
          final row = await _client
              .from('booking_disputes')
              .select()
              .eq('id', disputeId)
              .maybeSingle();
          if (row == null) return null;
          return BookingDispute.fromRow(row);
        },
      );

  /// Litige ouvert / en examen pour une réservation (s’il existe).
  Future<BookingDispute?> findActiveForReservation(String reservationId) =>
      SupabaseErrorHandler.run(
        operation: 'dispute.findActiveForReservation',
        action: () async {
          final rows = await _client
              .from('booking_disputes')
              .select()
              .eq('reservation_id', reservationId)
              .inFilter('status', ['open', 'under_review'])
              .order('created_at', ascending: false)
              .limit(1);
          final list = _decodeDisputes(rows);
          return list.isEmpty ? null : list.first;
        },
      );

  Future<List<DisputeMessage>> listMessages(String disputeId) =>
      SupabaseErrorHandler.run(
        operation: 'dispute.listMessages',
        action: () async {
          final rows = await _client
              .from('dispute_messages')
              .select()
              .eq('dispute_id', disputeId)
              .order('created_at', ascending: true);
          return _decodeMessages(rows);
        },
      );

  Future<void> sendMessage({
    required String disputeId,
    required String body,
    required DisputeSenderRole senderRole,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'dispute.sendMessage',
        action: () async {
          final userId = _client.auth.currentUser?.id;
          if (userId == null) {
            throw StateError('Utilisateur non connecté');
          }
          final text = body.trim();
          if (text.isEmpty) {
            throw ArgumentError('Message vide');
          }
          await _client.from('dispute_messages').insert({
            'dispute_id': disputeId,
            'sender_user_id': userId,
            'sender_role': senderRole.value,
            'body': text,
          });
        },
      );

  Future<List<BookingDispute>> adminList({
    bool openOnly = false,
    int limit = 80,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'dispute.adminList',
        action: () async {
          var query = _client.from('booking_disputes').select();
          if (openOnly) {
            query = query.inFilter('status', ['open', 'under_review']);
          }
          final rows = await query
              .order('created_at', ascending: false)
              .limit(limit.clamp(1, 200));
          return _decodeDisputes(rows);
        },
      );

  Future<BookingDispute> adminResolve({
    required String disputeId,
    required DisputeStatus status,
    String? adminNotes,
    String? resolution,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'dispute.adminResolve',
        action: () async {
          final raw = await _client.rpc(
            'resolve_booking_dispute',
            params: {
              'p_dispute_id': disputeId,
              'p_status': status.value,
              'p_admin_notes': adminNotes?.trim().isNotEmpty == true
                  ? adminNotes!.trim()
                  : null,
              'p_resolution': resolution?.trim().isNotEmpty == true
                  ? resolution!.trim()
                  : null,
            },
          );
          final map = Map<String, dynamic>.from(raw as Map);
          return BookingDispute.fromRow(map);
        },
      );

  List<BookingDispute> _decodeDisputes(dynamic rows) {
    final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
    return [for (final row in list) BookingDispute.fromRow(row)];
  }

  List<DisputeMessage> _decodeMessages(dynamic rows) {
    final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
    return [for (final row in list) DisputeMessage.fromRow(row)];
  }
}

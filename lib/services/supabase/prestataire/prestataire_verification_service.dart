import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/prestataire/prestataire_verification_state.dart';
import '../supabase_service.dart';

class PrestataireVerificationException implements Exception {
  const PrestataireVerificationException(this.code);

  final String code;
}

class PrestataireVerificationEvent {
  const PrestataireVerificationEvent({
    required this.id,
    required this.action,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String action;
  final String? note;
  final DateTime createdAt;

  factory PrestataireVerificationEvent.fromRow(Map<String, dynamic> row) {
    return PrestataireVerificationEvent(
      id: row['id'] as String? ?? '',
      action: row['action'] as String? ?? '',
      note: (row['note'] as String?)?.trim(),
      createdAt: DateTime.tryParse((row['created_at'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

class PrestataireVerificationService {
  PrestataireVerificationService(this._client);

  final SupabaseClient _client;

  factory PrestataireVerificationService.fromEnv() =>
      PrestataireVerificationService(SupabaseService.client);

  Future<PrestataireVerificationState> fetchStatus() async {
    return SupabaseErrorHandler.run(
      operation: 'prestataireVerification.fetchStatus',
      action: () async {
        final userId = _client.auth.currentUser?.id;
        if (userId == null) return PrestataireVerificationState.empty();

        final raw = await _client.rpc('prestataire_verification_status');
        final Map<String, dynamic>? map = switch (raw) {
          final Map m => Map<String, dynamic>.from(m),
          final List list when list.isNotEmpty && list.first is Map =>
            Map<String, dynamic>.from(list.first as Map),
          _ => null,
        };
        if (map == null) return PrestataireVerificationState.empty();
        return PrestataireVerificationState.fromJson(map);
      },
    );
  }

  Future<void> requestVerification() async {
    await SupabaseErrorHandler.run(
      operation: 'prestataireVerification.request',
      action: () async {
        try {
          await _client.rpc('request_prestataire_verification');
        } on PostgrestException catch (e) {
          throw _mapError(e);
        }
      },
    );
  }

  Future<List<PrestataireVerificationEvent>> listRecentDecisionEvents({
    required DateTime since,
  }) async {
    return SupabaseErrorHandler.run(
      operation: 'prestataireVerification.listRecentDecisionEvents',
      action: () async {
        final userId = _client.auth.currentUser?.id;
        if (userId == null) return const [];

        final rows = await _client
            .from('prestataire_verification_events')
            .select('id, action, note, created_at')
            .inFilter('action', ['approved', 'revoked'])
            .gte('created_at', since.toUtc().toIso8601String())
            .order('created_at', ascending: false)
            .limit(20);

        return (rows as List<dynamic>)
            .map((e) => PrestataireVerificationEvent.fromRow(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList();
      },
    );
  }

  static Exception _mapError(PostgrestException e) {
    final message = e.message.toLowerCase();
    if (message.contains('already_verified')) {
      return const PrestataireVerificationException('already_verified');
    }
    if (message.contains('verification_already_pending')) {
      return const PrestataireVerificationException('already_pending');
    }
    return e;
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../supabase_service.dart';

/// Événement de modération visible par l'utilisateur (avertissement, retrait photo).
class AccountModerationEvent {
  const AccountModerationEvent({
    required this.id,
    required this.eventType,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String eventType;
  final String message;
  final DateTime createdAt;
}

class AccountModerationService {
  AccountModerationService(this._client);

  final SupabaseClient _client;

  factory AccountModerationService.fromEnv() =>
      AccountModerationService(SupabaseService.client);

  Future<List<AccountModerationEvent>> listRecentForCurrentUser({
    DateTime? since,
  }) async {
    return SupabaseErrorHandler.run(
      operation: 'accountModeration.listRecent',
      action: () async {
        final userId = _client.auth.currentUser?.id;
        if (userId == null) return const [];

        var query = _client
            .from('account_moderation_events')
            .select('id, event_type, message, created_at')
            .eq('user_id', userId);

        if (since != null) {
          query = query.gte(
            'created_at',
            since.toUtc().toIso8601String(),
          );
        }

        final rows = await query
            .order('created_at', ascending: false)
            .limit(20);
        return (rows as List<dynamic>).map((raw) {
          final row = raw as Map<String, dynamic>;
          return AccountModerationEvent(
            id: row['id'] as String? ?? '',
            eventType: row['event_type'] as String? ?? '',
            message: row['message'] as String? ?? '',
            createdAt: DateTime.tryParse(
                  (row['created_at'] as String?) ?? '',
                ) ??
                DateTime.fromMillisecondsSinceEpoch(0),
          );
        }).toList();
      },
    );
  }
}

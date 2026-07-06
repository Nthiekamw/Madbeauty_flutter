import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/bug_report_message.dart';
import '../../../core/utils/safe_broadcast_stream.dart';

class BugReportMessageService {
  BugReportMessageService(this._client);

  final SupabaseClient _client;

  Future<void> send({
    required String bugReportId,
    required String content,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'bugReportMessage.send',
        action: () async {
          final userId = _client.auth.currentUser?.id;
          if (userId == null) {
            throw StateError('Utilisateur non connecté');
          }
          final text = content.trim();
          if (text.isEmpty) {
            throw ArgumentError('Message vide');
          }
          final report = await _client
              .from('bug_reports')
              .select('status')
              .eq('id', bugReportId)
              .maybeSingle();
          final status = report?['status'] as String? ?? '';
          if (status == 'resolved' || status == 'closed') {
            throw StateError('Discussion clôturée');
          }
          await _client.from('bug_report_messages').insert({
            'bug_report_id': bugReportId,
            'sender_id': userId,
            'content': text,
          });
        },
      );

  Future<void> markAsDelivered({
    required String bugReportId,
    required String userId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'bugReportMessage.markAsDelivered',
        action: () async {
          final now = DateTime.now().toUtc().toIso8601String();
          await _client
              .from('bug_report_messages')
              .update({'delivered_at': now})
              .eq('bug_report_id', bugReportId)
              .neq('sender_id', userId)
              .isFilter('delivered_at', null);
        },
      );

  Future<void> markAsRead({
    required String bugReportId,
    required String userId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'bugReportMessage.markAsRead',
        action: () async {
          await markAsDelivered(bugReportId: bugReportId, userId: userId);
          await _client
              .from('bug_report_messages')
              .update({'is_read': true})
              .eq('bug_report_id', bugReportId)
              .neq('sender_id', userId)
              .eq('is_read', false);
        },
      );

  Stream<List<BugReportMessage>> watchMessages(String bugReportId) {
    final safe = SafeBroadcastStream<List<BugReportMessage>>();
    RealtimeChannel? channel;
    StreamSubscription<List<Map<String, dynamic>>>? streamSub;

    Future<void> emitLatest() async {
      if (!safe.isActive) return;
      try {
        final list = await _fetch(bugReportId);
        safe.add(list);
      } catch (e, st) {
        safe.addError(e, st);
      }
    }

    void startListening() {
      unawaited(() async {
        await emitLatest();
        if (!safe.isActive) return;

        streamSub = _client
            .from('bug_report_messages')
            .stream(primaryKey: ['id'])
            .eq('bug_report_id', bugReportId)
            .order('created_at', ascending: true)
            .listen(
              (rows) {
                if (!safe.isActive) return;
                safe.add(_decode(rows));
              },
              onError: safe.addError,
            );

        if (!safe.isActive) {
          await streamSub?.cancel();
          streamSub = null;
          return;
        }

        channel = _client
            .channel('bug-report-messages-$bugReportId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'bug_report_messages',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'bug_report_id',
                value: bugReportId,
              ),
              callback: (_) {
                if (safe.isActive) unawaited(emitLatest());
              },
            )
            .subscribe();
      }());
    }

    safe.bind(
      onListen: startListening,
      cleanup: () async {
        await streamSub?.cancel();
        streamSub = null;
        final ch = channel;
        channel = null;
        if (ch != null) {
          await _client.removeChannel(ch);
        }
      },
    );

    return safe.stream;
  }

  Future<List<BugReportMessage>> _fetch(String bugReportId) async {
    final rows = await _client
        .from('bug_report_messages')
        .select()
        .eq('bug_report_id', bugReportId)
        .order('created_at', ascending: true);
    return _decode((rows as List<dynamic>).cast<Map<String, dynamic>>());
  }

  List<BugReportMessage> _decode(List<Map<String, dynamic>> rows) {
    return [for (final row in rows) BugReportMessage.fromRow(row)];
  }
}

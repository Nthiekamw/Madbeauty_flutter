import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/bug_report_message.dart';

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

  Stream<List<BugReportMessage>> watchMessages(String bugReportId) {
    final controller = StreamController<List<BugReportMessage>>.broadcast();
    StreamSubscription<List<Map<String, dynamic>>>? streamSub;

    Future<void> emitLatest() async {
      try {
        final list = await _fetch(bugReportId);
        if (!controller.isClosed) controller.add(list);
      } catch (e, st) {
        if (!controller.isClosed) controller.addError(e, st);
      }
    }

    controller.onListen = () async {
      await emitLatest();
      streamSub = _client
          .from('bug_report_messages')
          .stream(primaryKey: ['id'])
          .eq('bug_report_id', bugReportId)
          .order('created_at', ascending: true)
          .listen(
            (rows) {
              if (controller.isClosed) return;
              controller.add(_decode(rows));
            },
            onError: controller.addError,
          );
    };

    controller.onCancel = () async {
      await streamSub?.cancel();
    };

    return controller.stream;
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

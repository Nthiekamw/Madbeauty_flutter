import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/user_support_message.dart';

class UserSupportMessageService {
  UserSupportMessageService(this._client);

  final SupabaseClient _client;

  Future<void> send({
    required String threadId,
    required String content,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'userSupportMessage.send',
        action: () async {
          final userId = _client.auth.currentUser?.id;
          if (userId == null) {
            throw StateError('Utilisateur non connecté');
          }
          final text = content.trim();
          if (text.isEmpty) {
            throw ArgumentError('Message vide');
          }
          await _client.from('user_support_messages').insert({
            'thread_id': threadId,
            'sender_id': userId,
            'content': text,
          });
        },
      );

  Future<void> markAsDelivered({
    required String threadId,
    required String userId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'userSupportMessage.markAsDelivered',
        action: () async {
          final now = DateTime.now().toUtc().toIso8601String();
          await _client
              .from('user_support_messages')
              .update({'delivered_at': now})
              .eq('thread_id', threadId)
              .neq('sender_id', userId)
              .isFilter('delivered_at', null);
        },
      );

  Future<void> markAsRead({
    required String threadId,
    required String userId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'userSupportMessage.markAsRead',
        action: () async {
          await markAsDelivered(threadId: threadId, userId: userId);
          await _client
              .from('user_support_messages')
              .update({'is_read': true})
              .eq('thread_id', threadId)
              .neq('sender_id', userId)
              .eq('is_read', false);
        },
      );

  Stream<List<UserSupportMessage>> watchMessages(String threadId) {
    final controller = StreamController<List<UserSupportMessage>>.broadcast();
    RealtimeChannel? channel;
    StreamSubscription<List<Map<String, dynamic>>>? streamSub;

    Future<void> emitLatest() async {
      try {
        final list = await _fetch(threadId);
        if (!controller.isClosed) controller.add(list);
      } catch (e, st) {
        if (!controller.isClosed) controller.addError(e, st);
      }
    }

    controller.onListen = () async {
      await emitLatest();
      streamSub = _client
          .from('user_support_messages')
          .stream(primaryKey: ['id'])
          .eq('thread_id', threadId)
          .order('created_at', ascending: true)
          .listen(
            (rows) {
              if (controller.isClosed) return;
              controller.add(_decode(rows));
            },
            onError: controller.addError,
          );

      channel = _client
          .channel('user-support-messages-$threadId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'user_support_messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'thread_id',
              value: threadId,
            ),
            callback: (_) => unawaited(emitLatest()),
          )
          .subscribe();
    };

    controller.onCancel = () async {
      await streamSub?.cancel();
      final ch = channel;
      if (ch != null) {
        await _client.removeChannel(ch);
      }
      if (!controller.isClosed) await controller.close();
    };

    return controller.stream;
  }

  Future<List<UserSupportMessage>> _fetch(String threadId) async {
    final rows = await _client
        .from('user_support_messages')
        .select()
        .eq('thread_id', threadId)
        .order('created_at', ascending: true);
    return _decode((rows as List<dynamic>).cast<Map<String, dynamic>>());
  }

  List<UserSupportMessage> _decode(List<Map<String, dynamic>> rows) {
    return [for (final row in rows) UserSupportMessage.fromRow(row)];
  }
}

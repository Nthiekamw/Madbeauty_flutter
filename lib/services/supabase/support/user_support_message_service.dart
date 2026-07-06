import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/user_support_message.dart';
import '../../../core/utils/safe_broadcast_stream.dart';

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

  Future<List<UserSupportMessage>> listUnreadFromOthers({
    required String threadId,
    required String userId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'userSupportMessage.listUnreadFromOthers',
        action: () async {
          final rows = await _client
              .from('user_support_messages')
              .select()
              .eq('thread_id', threadId)
              .neq('sender_id', userId)
              .eq('is_read', false)
              .order('created_at', ascending: false);
          return _decode((rows as List<dynamic>).cast<Map<String, dynamic>>());
        },
      );

  Future<int> countUnreadFromOthers({
    required String threadId,
    required String userId,
  }) async {
    final list = await listUnreadFromOthers(
      threadId: threadId,
      userId: userId,
    );
    return list.length;
  }

  Stream<List<UserSupportMessage>> watchMessages(String threadId) {
    final safe = SafeBroadcastStream<List<UserSupportMessage>>();
    RealtimeChannel? channel;
    StreamSubscription<List<Map<String, dynamic>>>? streamSub;

    Future<void> emitLatest() async {
      if (!safe.isActive) return;
      try {
        final list = await _fetch(threadId);
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
            .from('user_support_messages')
            .stream(primaryKey: ['id'])
            .eq('thread_id', threadId)
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

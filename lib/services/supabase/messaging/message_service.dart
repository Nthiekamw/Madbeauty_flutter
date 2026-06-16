import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/messaging/conversation.dart';
import '../../../core/models/domain/messaging/message.dart';
import '../../../core/models/domain/serialization/supabase_domain_codec.dart';
import '../../../core/logic/messaging/chat_message_moderator.dart';

/// Couche data messagerie (réservation / booking + Supabase Realtime).
class MessageService {
  MessageService(this._client);

  final SupabaseClient _client;

  /// Crée le fil metadata si besoin (table `conversations`).
  Future<Conversation> ensureThreadForBooking(String bookingId) =>
      SupabaseErrorHandler.run(
        operation: 'message.ensureThreadForBooking',
        action: () async {
          final existing = await _client
              .from('conversations')
              .select()
              .eq('reservation_id', bookingId)
              .maybeSingle();
          if (existing != null) {
            return SupabaseDomainCodec.conversation(
              Map<String, dynamic>.from(existing),
            );
          }

          final reservation = await _client
              .from('reservations')
              .select('client_id, prestataire_id')
              .eq('id', bookingId)
              .single();

          final row = Map<String, dynamic>.from(reservation);
          final inserted = await _client
              .from('conversations')
              .insert({
                'client_id': row['client_id'],
                'prestataire_id': row['prestataire_id'],
                'reservation_id': bookingId,
              })
              .select()
              .single();

          return SupabaseDomainCodec.conversation(
            Map<String, dynamic>.from(inserted),
          );
        },
      );

  /// Envoie un message sur le booking.
  Future<void> send({
    required String bookingId,
    required String senderId,
    required String content,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'message.send',
        action: () async {
          final text = content.trim();
          if (text.isEmpty) {
            throw ArgumentError('Le contenu du message est vide.');
          }
          final recentRows = await _client
              .from('messages')
              .select('content, contenu')
              .eq('booking_id', bookingId)
              .eq('sender_id', senderId)
              .order('created_at', ascending: false)
              .limit(5);
          final recentOutgoing = <String>[];
          final rows = (recentRows as List<dynamic>).reversed;
          for (final raw in rows) {
            final row = Map<String, dynamic>.from(raw as Map);
            final body = (row['content'] as String?)?.trim() ??
                (row['contenu'] as String?)?.trim() ??
                '';
            if (body.isNotEmpty) recentOutgoing.add(body);
          }
          final moderation = ChatMessageModerator.analyze(
            text,
            context: ChatMessageModerationContext(
              recentOutgoingMessages: recentOutgoing,
            ),
          );
          if (moderation.isBlocked) {
            throw MessageValidationException(moderation.primary!);
          }
          final thread = await ensureThreadForBooking(bookingId);
          await _client.from('messages').insert({
            'booking_id': bookingId,
            'conversation_id': thread.id,
            'sender_id': senderId,
            'content': text,
            'contenu': text,
          });
        },
      );

  /// Envoie une photo sur le fil de réservation.
  Future<void> sendImage({
    required String bookingId,
    required String senderId,
    required String imageUrl,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'message.sendImage',
        action: () async {
          final url = imageUrl.trim();
          if (url.isEmpty) {
            throw ArgumentError('L’URL de l’image est vide.');
          }
          final thread = await ensureThreadForBooking(bookingId);
          await _client.from('messages').insert({
            'booking_id': bookingId,
            'conversation_id': thread.id,
            'sender_id': senderId,
            'content': DiscChat.imageMessagePreview,
            'contenu': DiscChat.imageMessagePreview,
            'image_url': url,
          });
        },
      );

  /// Flux temps réel des messages d'une réservation.
  Stream<List<Message>> getMessages(String bookingId) => watchMessages(bookingId);

  Stream<List<Message>> watchMessages(String bookingId) {
    final controller = StreamController<List<Message>>.broadcast();
    RealtimeChannel? channel;
    StreamSubscription<List<Map<String, dynamic>>>? streamSub;

    Future<void> emitLatest() async {
      try {
        final list = await _fetchMessages(bookingId);
        if (!controller.isClosed) controller.add(list);
      } catch (e, st) {
        if (!controller.isClosed) controller.addError(e, st);
      }
    }

    controller.onListen = () async {
      await emitLatest();

      streamSub = _client
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('booking_id', bookingId)
          .order('created_at', ascending: true)
          .listen(
            (rows) {
              if (controller.isClosed) return;
              controller.add(_decodeMessages(rows));
            },
            onError: controller.addError,
          );

      channel = _client
          .channel('messages-booking-$bookingId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'booking_id',
              value: bookingId,
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

  /// Marque comme livrés les messages reçus sur ce booking.
  Future<void> markAsDelivered({
    required String bookingId,
    required String userId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'message.markAsDelivered',
        action: () async {
          final now = DateTime.now().toUtc().toIso8601String();
          await _client
              .from('messages')
              .update({'delivered_at': now})
              .eq('booking_id', bookingId)
              .neq('sender_id', userId)
              .isFilter('delivered_at', null);
        },
      );

  /// Marque comme lus les messages reçus sur ce booking.
  Future<void> markAsRead({
    required String bookingId,
    required String userId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'message.markAsRead',
        action: () async {
          await markAsDelivered(bookingId: bookingId, userId: userId);
          await _client
              .from('messages')
              .update({'is_read': true})
              .eq('booking_id', bookingId)
              .neq('sender_id', userId)
              .eq('is_read', false);
        },
      );

  /// Fils de discussion de l'utilisateur connecté ([userId] = auth.users.id).
  Future<List<Conversation>> getConversations(String userId) =>
      SupabaseErrorHandler.run(
        operation: 'message.getConversations',
        action: () async {
          final byId = <String, Conversation>{};

          void addRows(List<dynamic> rows) {
            for (final raw in rows) {
              final conv = SupabaseDomainCodec.conversation(
                Map<String, dynamic>.from(raw as Map),
              );
              byId[conv.id] = conv;
            }
          }

          final clientProfile = await _client
              .from('client_profiles')
              .select('id')
              .eq('user_id', userId)
              .maybeSingle();
          if (clientProfile != null) {
            final clientId = (clientProfile as Map)['id'] as String;
            final rows = await _client
                .from('conversations')
                .select()
                .eq('client_id', clientId)
                .order('last_message_at', ascending: false);
            addRows(rows as List<dynamic>);
          }

          final prestaProfile = await _client
              .from('prestataire_profiles')
              .select('id')
              .eq('user_id', userId)
              .maybeSingle();
          if (prestaProfile != null) {
            final prestaId = (prestaProfile as Map)['id'] as String;
            final rows = await _client
                .from('conversations')
                .select()
                .eq('prestataire_id', prestaId)
                .order('last_message_at', ascending: false);
            addRows(rows as List<dynamic>);
          }

          final list = byId.values.toList()
            ..sort((a, b) {
              final ta = a.lastMessageAt;
              final tb = b.lastMessageAt;
              if (ta == null && tb == null) return 0;
              if (ta == null) return 1;
              if (tb == null) return -1;
              return tb.compareTo(ta);
            });

          return list;
        },
      );

  Future<List<Message>> _fetchMessages(String bookingId) async {
    final response = await _client
        .from('messages')
        .select()
        .eq('booking_id', bookingId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: true);
    return _decodeMessages(response as List<dynamic>);
  }

  /// Supprime un message envoyé par l’utilisateur connecté.
  Future<void> deleteMessage({
    required String messageId,
    required String bookingId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'message.deleteMessage',
        action: () async {
          await _client
              .from('messages')
              .delete()
              .eq('id', messageId)
              .eq('booking_id', bookingId);
        },
      );

  /// Supprime tous les messages et le fil metadata de la réservation.
  Future<void> deleteChat({required String bookingId}) =>
      SupabaseErrorHandler.run(
        operation: 'message.deleteChat',
        action: () async {
          await _client.rpc(
            'delete_booking_chat',
            params: {'p_booking_id': bookingId},
          );
        },
      );

  List<Message> _decodeMessages(List<dynamic> rows) {
    return [
      for (final raw in rows)
        if ((raw as Map)['deleted_at'] == null)
          SupabaseDomainCodec.message(
            Map<String, dynamic>.from(raw),
          ),
    ];
  }

  Future<int> countUnreadForUser({
    required String userId,
    required MessagingParticipantRole role,
    required String profileId,
  }) async {
    final column =
        role == MessagingParticipantRole.client ? 'client_id' : 'prestataire_id';

    final convRows = await _client
        .from('conversations')
        .select('id')
        .eq(column, profileId);

    final convIds = (convRows as List)
        .map((r) => (r as Map)['id'] as String)
        .toList();
    if (convIds.isEmpty) return 0;

    final bookingRows = await _client
        .from('conversations')
        .select('reservation_id')
        .inFilter('id', convIds);

    final bookingIds = (bookingRows as List)
        .map((r) => (r as Map)['reservation_id'] as String?)
        .whereType<String>()
        .toList();
    if (bookingIds.isEmpty) return 0;

    final unread = await _client
        .from('messages')
        .select('id')
        .inFilter('booking_id', bookingIds)
        .eq('is_read', false)
        .neq('sender_id', userId);

    return (unread as List).length;
  }

  Future<Map<String, Message>> latestMessageByBookingIds(
    List<String> bookingIds,
  ) async {
    if (bookingIds.isEmpty) return {};

    final response = await _client
        .from('messages')
        .select()
        .inFilter('booking_id', bookingIds)
        .order('created_at', ascending: false);

    final out = <String, Message>{};
    for (final raw in response as List<dynamic>) {
      final msg = SupabaseDomainCodec.message(
        Map<String, dynamic>.from(raw as Map),
      );
      out.putIfAbsent(msg.bookingId, () => msg);
    }
    return out;
  }

  Future<Map<String, int>> unreadCountByBookingIds(
    List<String> bookingIds, {
    required String currentUserId,
  }) async {
    if (bookingIds.isEmpty) return {};

    final response = await _client
        .from('messages')
        .select('booking_id')
        .inFilter('booking_id', bookingIds)
        .eq('is_read', false)
        .neq('sender_id', currentUserId);

    final counts = <String, int>{};
    for (final raw in response as List<dynamic>) {
      final id = (raw as Map)['booking_id'] as String;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    return counts;
  }
}

enum MessagingParticipantRole { client, prestataire }

class MessageValidationException implements Exception {
  MessageValidationException(this.violation) : code = violation.name;

  MessageValidationException.phoneNumberNotAllowed()
      : violation = ChatMessageViolationType.phoneNumber,
        code = ChatMessageViolationType.phoneNumber.name;

  final ChatMessageViolationType violation;
  final String code;
}

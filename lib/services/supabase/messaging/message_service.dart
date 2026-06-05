import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/messaging/conversation.dart';
import '../../../core/models/domain/messaging/message.dart';
import '../../../core/models/domain/serialization/supabase_domain_codec.dart';
import '../../../features/messaging/logic/chat_message_moderator.dart';

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
          final moderation = ChatMessageModerator.analyze(text);
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

  /// Marque comme lus les messages reçus sur ce booking.
  Future<void> markAsRead({
    required String bookingId,
    required String userId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'message.markAsRead',
        action: () async {
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
        .order('created_at', ascending: true);
    return _decodeMessages(response as List<dynamic>);
  }

  List<Message> _decodeMessages(List<dynamic> rows) {
    return [
      for (final raw in rows)
        SupabaseDomainCodec.message(
          Map<String, dynamic>.from(raw as Map),
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

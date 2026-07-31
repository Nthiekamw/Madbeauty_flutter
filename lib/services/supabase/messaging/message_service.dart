import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/logic/messaging/reservation_chat_eligibility.dart';
import '../../../core/logic/messaging/chat_message_moderator.dart';
import '../../../core/models/domain/messaging/conversation.dart';
import '../../../core/models/domain/messaging/message.dart';
import '../../../core/models/domain/serialization/supabase_domain_codec.dart';
import '../../../core/utils/safe_broadcast_stream.dart';

/// Couche data messagerie (fil par paire client/prestataire + Supabase Realtime).
class MessageService {
  MessageService(this._client);

  final SupabaseClient _client;

  Future<Conversation?> getConversation(String conversationId) =>
      SupabaseErrorHandler.run(
        operation: 'message.getConversation',
        action: () async {
          final row = await _client
              .from('conversations')
              .select()
              .eq('id', conversationId)
              .maybeSingle();
          if (row == null) return null;
          return SupabaseDomainCodec.conversation(
            Map<String, dynamic>.from(row),
          );
        },
      );

  /// Crée ou récupère le fil unique client ↔ prestataire.
  Future<Conversation> ensureThreadForPair({
    required String clientId,
    required String prestataireId,
    String? reservationId,
    String kind = 'booking',
  }) =>
      SupabaseErrorHandler.run(
        operation: 'message.ensureThreadForPair',
        action: () async {
          final existing = await _client
              .from('conversations')
              .select()
              .eq('client_id', clientId)
              .eq('prestataire_id', prestataireId)
              .maybeSingle();
          if (existing != null) {
            final conv = SupabaseDomainCodec.conversation(
              Map<String, dynamic>.from(existing),
            );
            final updates = <String, dynamic>{};
            if (reservationId != null &&
                reservationId.isNotEmpty &&
                conv.reservationId != reservationId) {
              updates['reservation_id'] = reservationId;
            }
            if (kind == 'booking' && conv.kind == 'inquiry') {
              updates['kind'] = 'booking';
            }
            if (kind == 'inquiry' &&
                conv.kind != 'inquiry' &&
                (conv.reservationId == null ||
                    conv.reservationId!.trim().isEmpty)) {
              updates['kind'] = 'inquiry';
            }
            if (updates.isNotEmpty) {
              await _client
                  .from('conversations')
                  .update(updates)
                  .eq('id', conv.id);
              return conv.copyWith(
                reservationId: updates['reservation_id'] as String? ??
                    conv.reservationId,
                kind: updates['kind'] as String? ?? conv.kind,
              );
            }
            return conv;
          }

          final inserted = await _client
              .from('conversations')
              .insert({
                'client_id': clientId,
                'prestataire_id': prestataireId,
                'kind': kind,
                if (reservationId != null && reservationId.isNotEmpty)
                  'reservation_id': reservationId,
              })
              .select()
              .single();

          return SupabaseDomainCodec.conversation(
            Map<String, dynamic>.from(inserted),
          );
        },
      );

  /// Fil devis / conseil (sans réservation).
  Future<Conversation> ensureInquiryThread({
    required String clientId,
    required String prestataireId,
  }) =>
      ensureThreadForPair(
        clientId: clientId,
        prestataireId: prestataireId,
        kind: 'inquiry',
      );

  /// Retourne un booking_id si disponible, sinon null (inquiry autorisé).
  Future<String?> resolveBookingContextForSendOptional(
    Conversation thread,
  ) async {
    try {
      return await resolveBookingContextForSend(thread);
    } catch (_) {
      if (thread.kind == 'inquiry' || thread.reservationId == null) {
        return null;
      }
      rethrow;
    }
  }

  /// Ouvre le fil lié à une réservation (réutilise le fil paire client/prestataire).
  Future<Conversation> ensureThreadForBooking(String bookingId) =>
      SupabaseErrorHandler.run(
        operation: 'message.ensureThreadForBooking',
        action: () async {
          final reservation = await _client
              .from('reservations')
              .select('client_id, prestataire_id')
              .eq('id', bookingId)
              .single();

          final row = Map<String, dynamic>.from(reservation);
          return ensureThreadForPair(
            clientId: row['client_id'] as String,
            prestataireId: row['prestataire_id'] as String,
            reservationId: bookingId,
          );
        },
      );

  Future<String> resolveBookingContextForSend(Conversation thread) async {
    final cached = thread.reservationId?.trim();
    if (cached != null && cached.isNotEmpty) {
      final row = await _client
          .from('reservations')
          .select('statut')
          .eq('id', cached)
          .maybeSingle();
      final statut = row?['statut'];
      if (statut is String && reservationStatutAllowsChat(statut)) {
        return cached;
      }
    }

    final rows = await _client
        .from('reservations')
        .select('id, statut, date_heure')
        .eq('client_id', thread.clientId)
        .eq('prestataire_id', thread.prestataireId)
        .order('date_heure', ascending: false)
        .limit(30);

    for (final raw in rows as List<dynamic>) {
      final m = Map<String, dynamic>.from(raw as Map);
      final id = m['id'] as String?;
      final statut = m['statut'];
      if (id == null || id.isEmpty) continue;
      if (statut is String && reservationStatutAllowsChat(statut)) {
        return id;
      }
    }

    for (final raw in rows as List<dynamic>) {
      final id = (raw as Map)['id'] as String?;
      if (id != null && id.isNotEmpty) return id;
    }

    throw StateError('Aucune réservation pour contextualiser ce message.');
  }

  Future<void> send({
    required String conversationId,
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

          final thread = await getConversation(conversationId);
          if (thread == null) {
            throw StateError('Conversation introuvable.');
          }
          final bookingId =
              await resolveBookingContextForSendOptional(thread);

          final recentRows = await _client
              .from('messages')
              .select('content, contenu')
              .eq('conversation_id', conversationId)
              .eq('sender_id', senderId)
              .order('created_at', ascending: false)
              .limit(5);
          final recentOutgoing = <String>[];
          for (final raw in (recentRows as List<dynamic>).reversed) {
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

          await _client.from('messages').insert({
            if (bookingId != null) 'booking_id': bookingId,
            'conversation_id': conversationId,
            'sender_id': senderId,
            'content': text,
            'contenu': text,
          });
        },
      );

  Future<void> sendImage({
    required String conversationId,
    required String senderId,
    required String imageUrl,
    String kind = 'image',
    String? resultLabel,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'message.sendImage',
        action: () async {
          final url = imageUrl.trim();
          if (url.isEmpty) {
            throw ArgumentError('L’URL de l’image est vide.');
          }
          final thread = await getConversation(conversationId);
          if (thread == null) {
            throw StateError('Conversation introuvable.');
          }
          final bookingId =
              await resolveBookingContextForSendOptional(thread);

          final resolvedKind =
              kind == 'result_media' ? 'result_media' : 'image';
          final label = resolvedKind == 'result_media'
              ? (resultLabel ?? 'result')
              : null;

          await _client.from('messages').insert({
            if (bookingId != null) 'booking_id': bookingId,
            'conversation_id': conversationId,
            'sender_id': senderId,
            'content': resolvedKind == 'result_media'
                ? DiscChat.resultMediaPreview
                : DiscChat.imageMessagePreview,
            'contenu': resolvedKind == 'result_media'
                ? DiscChat.resultMediaPreview
                : DiscChat.imageMessagePreview,
            'image_url': url,
            'kind': resolvedKind,
            if (label != null) 'result_label': label,
          });
        },
      );

  Stream<List<Message>> getMessages(String conversationId) =>
      watchMessages(conversationId);

  Stream<List<Message>> watchMessages(String conversationId) {
    final safe = SafeBroadcastStream<List<Message>>();
    RealtimeChannel? channel;
    StreamSubscription<List<Map<String, dynamic>>>? streamSub;

    Future<void> emitLatest() async {
      if (!safe.isActive) return;
      try {
        final list = await _fetchMessages(conversationId);
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
            .from('messages')
            .stream(primaryKey: ['id'])
            .eq('conversation_id', conversationId)
            .order('created_at', ascending: true)
            .listen(
              (_) => unawaited(emitLatest()),
              onError: safe.addError,
            );

        if (!safe.isActive) {
          await streamSub?.cancel();
          streamSub = null;
          return;
        }

        channel = _client
            .channel('messages-conversation-$conversationId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'messages',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'conversation_id',
                value: conversationId,
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

  Future<void> markAsDelivered({
    required String conversationId,
    required String userId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'message.markAsDelivered',
        action: () async {
          final now = DateTime.now().toUtc().toIso8601String();
          await _client
              .from('messages')
              .update({'delivered_at': now})
              .eq('conversation_id', conversationId)
              .neq('sender_id', userId)
              .isFilter('delivered_at', null);
        },
      );

  Future<void> markAsRead({
    required String conversationId,
    required String userId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'message.markAsRead',
        action: () async {
          await markAsDelivered(conversationId: conversationId, userId: userId);
          await _client
              .from('messages')
              .update({'is_read': true})
              .eq('conversation_id', conversationId)
              .neq('sender_id', userId)
              .eq('is_read', false);
        },
      );

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

  Future<List<Message>> _fetchMessages(String conversationId) async {
    final response = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: true);
    return _decodeMessages(response as List<dynamic>);
  }

  Future<void> deleteMessage({
    required String messageId,
    required String conversationId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'message.deleteMessage',
        action: () async {
          await _client
              .from('messages')
              .delete()
              .eq('id', messageId)
              .eq('conversation_id', conversationId);
        },
      );

  Future<void> deleteConversation({required String conversationId}) =>
      SupabaseErrorHandler.run(
        operation: 'message.deleteConversation',
        action: () async {
          await _client.rpc(
            'delete_conversation_chat',
            params: {'p_conversation_id': conversationId},
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

    final unread = await _client
        .from('messages')
        .select('id')
        .inFilter('conversation_id', convIds)
        .eq('is_read', false)
        .neq('sender_id', userId);

    return (unread as List).length;
  }

  Future<Map<String, Message>> latestMessageByConversationIds(
    List<String> conversationIds,
  ) async {
    if (conversationIds.isEmpty) return {};

    final response = await _client
        .from('messages')
        .select()
        .inFilter('conversation_id', conversationIds)
        .order('created_at', ascending: false);

    final out = <String, Message>{};
    for (final raw in response as List<dynamic>) {
      final row = Map<String, dynamic>.from(raw as Map);
      final msg = SupabaseDomainCodec.message(row);
      final convId = row['conversation_id'] as String?;
      if (convId != null) {
        out.putIfAbsent(convId, () => msg);
      }
    }
    return out;
  }

  Future<Map<String, int>> unreadCountByConversationIds(
    List<String> conversationIds, {
    required String currentUserId,
  }) async {
    if (conversationIds.isEmpty) return {};

    final response = await _client
        .from('messages')
        .select('conversation_id')
        .inFilter('conversation_id', conversationIds)
        .eq('is_read', false)
        .neq('sender_id', currentUserId);

    final counts = <String, int>{};
    for (final raw in response as List<dynamic>) {
      final id = (raw as Map)['conversation_id'] as String;
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

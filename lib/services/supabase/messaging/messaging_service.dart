import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/messaging/conversation.dart';
import '../../../core/models/domain/messaging/message.dart';
import '../../../core/models/domain/serialization/supabase_domain_codec.dart';
import '../../../core/logic/messaging/reservation_chat_eligibility.dart';
import '../../../core/models/domain/messaging/client_presta_chat_access.dart';
import '../../../core/models/domain/messaging/conversation_inbox_item.dart';
import '../profile/profile_service.dart';
import 'message_service.dart';

/// Inbox enrichie (noms, réservation) – s'appuie sur [MessageService] pour les messages.
class MessagingService {
  MessagingService(
    this._client, {
    required MessageService messageService,
    required ProfileService profileService,
  })  : _messageService = messageService,
        _profileService = profileService;

  final SupabaseClient _client;
  final MessageService _messageService;
  final ProfileService _profileService;

  Future<Conversation> getOrCreateForReservation(String reservationId) =>
      _messageService.ensureThreadForBooking(reservationId);

  Future<Conversation?> getByConversationId(String conversationId) =>
      _messageService.getConversation(conversationId);

  Future<Conversation?> getByBookingId(String bookingId) =>
      SupabaseErrorHandler.run(
        operation: 'messaging.getByBookingId',
        action: () async {
          final row = await _client
              .from('reservations')
              .select('client_id, prestataire_id')
              .eq('id', bookingId)
              .maybeSingle();
          if (row == null) return null;
          final m = Map<String, dynamic>.from(row);
          final existing = await _client
              .from('conversations')
              .select()
              .eq('client_id', m['client_id'] as String)
              .eq('prestataire_id', m['prestataire_id'] as String)
              .maybeSingle();
          if (existing == null) return null;
          return SupabaseDomainCodec.conversation(
            Map<String, dynamic>.from(existing),
          );
        },
      );

  Future<ConversationInboxItem?> resolveInboxItemForConversation({
    required String conversationId,
    required String currentUserId,
    required bool peerIsPrestataire,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'messaging.resolveInboxItemForConversation',
        action: () async {
          final conv = await getByConversationId(conversationId);
          if (conv == null) return null;

          final lastByConv = await _messageService
              .latestMessageByConversationIds([conversationId]);
          final unreadByConv = await _messageService
              .unreadCountByConversationIds(
            [conversationId],
            currentUserId: currentUserId,
          );

          final reservationIds = <String>[
            if (conv.reservationId != null && conv.reservationId!.isNotEmpty)
              conv.reservationId!,
          ];
          final reservationMeta = await _reservationMetaById(reservationIds);

          final peerId =
              peerIsPrestataire ? conv.prestataireId : conv.clientId;
          final peerInfo = peerIsPrestataire
              ? await _prestatairePeerInfoById([peerId])
              : await _clientPeerInfoById([peerId]);

          final last = lastByConv[conversationId];
          final resId = conv.reservationId;

          return _toInboxItem(
            conv: conv,
            currentUserId: currentUserId,
            peer: peerInfo[peerId],
            peerIsPrestataire: peerIsPrestataire,
            last: last,
            unread: unreadByConv[conversationId] ?? 0,
            reservation: resId != null ? reservationMeta[resId] : null,
          );
        },
      );

  @Deprecated('Use resolveInboxItemForConversation')
  Future<ConversationInboxItem?> resolveInboxItemForBooking({
    required String bookingId,
    required String currentUserId,
    required bool peerIsPrestataire,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'messaging.resolveInboxItemForBooking',
        action: () async {
          final conv = await getByBookingId(bookingId);
          if (conv == null) return null;
          return resolveInboxItemForConversation(
            conversationId: conv.id,
            currentUserId: currentUserId,
            peerIsPrestataire: peerIsPrestataire,
          );
        },
      );

  Future<List<ConversationInboxItem>> listInboxForClient(
    String clientProfileId,
    String currentUserId,
  ) =>
      _listInbox(
        column: 'client_id',
        profileId: clientProfileId,
        currentUserId: currentUserId,
        peerIsPrestataire: true,
      );

  Future<List<ConversationInboxItem>> listInboxForPrestataire(
    String prestataireProfileId,
    String currentUserId,
  ) =>
      _listInbox(
        column: 'prestataire_id',
        profileId: prestataireProfileId,
        currentUserId: currentUserId,
        peerIsPrestataire: false,
      );

  Future<List<ConversationInboxItem>> _listInbox({
    required String column,
    required String profileId,
    required String currentUserId,
    required bool peerIsPrestataire,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'messaging.listInbox',
        action: () async {
          final byId = <String, Conversation>{};

          void addConversation(Conversation conv) {
            if (_conversationBelongsToInbox(
              conv,
              column: column,
              profileId: profileId,
            )) {
              byId[conv.id] = conv;
            }
          }

          final convRows = await _client
              .from('conversations')
              .select()
              .eq(column, profileId)
              .order('last_message_at', ascending: false);

          for (final raw in convRows as List<dynamic>) {
            addConversation(
              SupabaseDomainCodec.conversation(
                Map<String, dynamic>.from(raw as Map),
              ),
            );
          }

          final fromMessages = await _loadConversationsFromMessages(
            column: column,
            profileId: profileId,
          );
          for (final conv in fromMessages) {
            addConversation(conv);
          }

          for (final conv in await _messageService.getConversations(
            currentUserId,
          )) {
            addConversation(conv);
          }

          var conversations = byId.values.toList()
            ..sort((a, b) {
              final ta = a.lastMessageAt;
              final tb = b.lastMessageAt;
              if (ta == null && tb == null) return 0;
              if (ta == null) return 1;
              if (tb == null) return -1;
              return tb.compareTo(ta);
            });

          if (conversations.isEmpty) return [];

          final conversationIds = conversations.map((c) => c.id).toList();

          final lastByConv =
              await _messageService.latestMessageByConversationIds(
            conversationIds,
          );
          final unreadByConv =
              await _messageService.unreadCountByConversationIds(
            conversationIds,
            currentUserId: currentUserId,
          );

          final reservationIds = conversations
              .map((c) => c.reservationId)
              .whereType<String>()
              .where((id) => id.isNotEmpty)
              .toList();

          final reservationMeta =
              await _reservationMetaById(reservationIds);

          final peerIds = peerIsPrestataire
              ? conversations.map((c) => c.prestataireId).toSet().toList()
              : conversations.map((c) => c.clientId).toSet().toList();

          final peerInfo = peerIsPrestataire
              ? await _prestatairePeerInfoById(peerIds)
              : await _clientPeerInfoById(peerIds);

          return [
            for (final conv in conversations)
              _toInboxItem(
                conv: conv,
                currentUserId: currentUserId,
                peer: peerInfo[peerIsPrestataire
                    ? conv.prestataireId
                    : conv.clientId],
                peerIsPrestataire: peerIsPrestataire,
                last: lastByConv[conv.id],
                unread: unreadByConv[conv.id] ?? 0,
                reservation: conv.reservationId != null
                    ? reservationMeta[conv.reservationId!]
                    : null,
              ),
          ];
        },
      );

  Future<List<Conversation>> _loadConversationsFromMessages({
    required String column,
    required String profileId,
  }) async {
    final resRows = await _client
        .from('reservations')
        .select('id')
        .eq(column, profileId);

    final bookingIds = <String>{
      for (final raw in resRows as List<dynamic>)
        if ((raw as Map)['id'] is String) (raw)['id'] as String,
    };
    if (bookingIds.isEmpty) return const [];

    final msgRows = await _client
        .from('messages')
        .select('conversation_id')
        .inFilter('booking_id', bookingIds.toList())
        .isFilter('deleted_at', null);

    final convIds = <String>{
      for (final raw in msgRows as List<dynamic>)
        if ((raw as Map)['conversation_id'] is String)
          (raw)['conversation_id'] as String,
    };
    if (convIds.isEmpty) return const [];

    final convRows = await _client
        .from('conversations')
        .select()
        .inFilter('id', convIds.toList());

    return [
      for (final raw in convRows as List<dynamic>)
        SupabaseDomainCodec.conversation(
          Map<String, dynamic>.from(raw as Map),
        ),
    ].where((conv) => _conversationBelongsToInbox(
          conv,
          column: column,
          profileId: profileId,
          reservationIds: bookingIds,
        )).toList();
  }

  bool _conversationBelongsToInbox(
    Conversation conv, {
    required String column,
    required String profileId,
    Set<String>? reservationIds,
  }) {
    if (_conversationMatchesInboxColumn(
      conv,
      column: column,
      profileId: profileId,
    )) {
      return true;
    }
    final resId = conv.reservationId;
    if (resId != null &&
        resId.isNotEmpty &&
        reservationIds != null &&
        reservationIds.contains(resId)) {
      return true;
    }
    return false;
  }

  bool _conversationMatchesInboxColumn(
    Conversation conv, {
    required String column,
    required String profileId,
  }) {
    return switch (column) {
      'client_id' => conv.clientId == profileId,
      'prestataire_id' => conv.prestataireId == profileId,
      _ => false,
    };
  }

  ConversationInboxItem _toInboxItem({
    required Conversation conv,
    required String currentUserId,
    required _PeerInboxInfo? peer,
    required bool peerIsPrestataire,
    required Message? last,
    required int unread,
    required _ReservationMeta? reservation,
  }) {
    final fallbackName = peerIsPrestataire
        ? DiscBk.unknownPresta
        : DiscPrestaDash.unknownClient;

    return ConversationInboxItem(
      conversation: conv,
      peerDisplayName: peer?.displayName.trim().isNotEmpty == true
          ? peer!.displayName.trim()
          : fallbackName,
      peerPrenom: peerIsPrestataire ? null : peer?.prenom,
      peerNom: peerIsPrestataire ? null : peer?.nom,
      peerAvatarUrl: peer?.avatarUrl,
      peerLastSeenAt: peer?.lastSeenAt,
      showSalonName: peerIsPrestataire,
      lastMessagePreview: _messagePreview(last),
      lastMessageAt: last?.createdAt ?? conv.lastMessageAt,
      unreadCount: unread,
      reservationDate: reservation?.dateHeure,
      serviceName: reservation?.serviceName,
      isLastMessageMine: last?.senderId == currentUserId,
      isLastMessageReadByPeer: last == null || last.senderId != currentUserId
          ? true
          : last.isRead,
    );
  }

  String? _messagePreview(Message? last) {
    if (last == null) return null;
    final imageUrl = last.imageUrl?.trim();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return DiscChat.imageMessagePreview;
    }
    return last.content;
  }

  Future<Map<String, _ReservationMeta>> _reservationMetaById(
    List<String> reservationIds,
  ) async {
    if (reservationIds.isEmpty) return {};

    final response = await _client
        .from('reservations')
        .select('id, date_heure, service_id')
        .inFilter('id', reservationIds);

    final serviceIds = <String>{};
    final dateById = <String, DateTime>{};
    final serviceIdByRes = <String, String>{};

    for (final raw in response as List<dynamic>) {
      final m = Map<String, dynamic>.from(raw as Map);
      final id = m['id'] as String;
      final dt = DateTime.tryParse(m['date_heure'] as String? ?? '');
      if (dt != null) dateById[id] = dt;
      final sid = m['service_id'] as String?;
      if (sid != null) {
        serviceIds.add(sid);
        serviceIdByRes[id] = sid;
      }
    }

    final serviceNames = <String, String>{};
    if (serviceIds.isNotEmpty) {
      final svcRows = await _client
          .from('services_beaute')
          .select('id, nom')
          .inFilter('id', serviceIds.toList());
      for (final raw in svcRows as List<dynamic>) {
        final m = Map<String, dynamic>.from(raw as Map);
        serviceNames[m['id'] as String] = (m['nom'] as String?)?.trim() ?? '';
      }
    }

    return {
      for (final id in reservationIds)
        id: _ReservationMeta(
          dateHeure: dateById[id],
          serviceName: serviceNames[serviceIdByRes[id]],
        ),
    };
  }

  Future<Map<String, _PeerInboxInfo>> _prestatairePeerInfoById(
    List<String> prestataireIds,
  ) async {
    if (prestataireIds.isEmpty) return {};

    final response = await _client
        .from('prestataire_profiles')
        .select('id, nom_salon, nom_affiche, user_id')
        .inFilter('id', prestataireIds);

    final userIds = <String>[];
    final labelByPresta = <String, String>{};
    final userIdByPresta = <String, String>{};

    for (final raw in response as List<dynamic>) {
      final m = Map<String, dynamic>.from(raw as Map);
      final id = m['id'] as String;
      final salon = (m['nom_salon'] as String?)?.trim();
      final affiche = (m['nom_affiche'] as String?)?.trim();
      if (salon != null && salon.isNotEmpty) {
        labelByPresta[id] = salon;
      } else if (affiche != null && affiche.isNotEmpty) {
        labelByPresta[id] = affiche;
      }
      final uid = m['user_id'] as String?;
      if (uid != null) {
        userIds.add(uid);
        userIdByPresta[id] = uid;
      }
    }

    final profiles = await _profileService.getByUserIds(userIds);
    final lastSeenByUser = await _profileService.lastSeenByUserIds(userIds);
    final avatarByPresta = <String, String?>{};
    final lastSeenByPresta = <String, DateTime?>{};

    for (final raw in response as List<dynamic>) {
      final m = Map<String, dynamic>.from(raw as Map);
      final id = m['id'] as String;
      final uid = userIdByPresta[id];
      final p = uid != null ? profiles[uid] : null;

      labelByPresta.putIfAbsent(id, () => DiscBk.unknownPresta);

      avatarByPresta[id] = _normalizeAvatarUrl(p?.avatarUrl);
      if (uid != null) {
        lastSeenByPresta[id] = lastSeenByUser[uid];
      }
    }

    return {
      for (final id in prestataireIds)
        id: _PeerInboxInfo(
          displayName: labelByPresta[id] ?? DiscBk.unknownPresta,
          avatarUrl: avatarByPresta[id],
          lastSeenAt: lastSeenByPresta[id],
        ),
    };
  }

  /// Dernière réservation pour laquelle le chat est autorisé (confirmée / terminée).
  Future<String?> findLatestBookingIdForClientPrestaPair({
    required String clientProfileId,
    required String prestataireId,
  }) async {
    final access = await resolveClientChatAccess(
      clientProfileId: clientProfileId,
      prestataireId: prestataireId,
    );
    if (access.kind == ClientPrestaChatAccessKind.ready) {
      return access.bookingId;
    }
    return null;
  }

  /// État messagerie pour la fiche prestataire (côté cliente).
  Future<ClientPrestaChatAccess> resolveClientChatAccess({
    required String clientProfileId,
    required String prestataireId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'messaging.resolveClientChatAccess',
        action: () async {
          final resRows = await _client
              .from('reservations')
              .select('id, statut, date_heure')
              .eq('client_id', clientProfileId)
              .eq('prestataire_id', prestataireId)
              .order('date_heure', ascending: false);

          String? pendingId;
          String? readyId;

          for (final raw in resRows as List<dynamic>) {
            final m = Map<String, dynamic>.from(raw as Map);
            final id = m['id'] as String?;
            if (id == null || id.isEmpty) continue;
            final statut = m['statut'];
            if (statut is! String) continue;

            if (reservationStatutAllowsChat(statut)) {
              readyId ??= id;
              break;
            }
            if (reservationStatutIsPending(statut)) {
              pendingId ??= id;
            }
          }

          if (readyId != null) {
            return ClientPrestaChatAccess.ready(readyId);
          }
          if (pendingId != null) {
            return ClientPrestaChatAccess.awaiting(bookingId: pendingId);
          }

          final inquiryRow = await _client
              .from('conversations')
              .select('id')
              .eq('client_id', clientProfileId)
              .eq('prestataire_id', prestataireId)
              .eq('kind', 'inquiry')
              .maybeSingle();
          final inquiryId = inquiryRow?['id'] as String?;
          return ClientPrestaChatAccess.inquiry(
            conversationId: inquiryId,
          );
        },
      );

  /// Vérifie qu'une réservation autorise l'ouverture du chat.
  Future<bool> isChatOpenForBooking(String bookingId) =>
      SupabaseErrorHandler.run(
        operation: 'messaging.isChatOpenForBooking',
        action: () async {
          final row = await _client
              .from('reservations')
              .select('statut')
              .eq('id', bookingId)
              .maybeSingle();
          if (row == null) return false;
          final statut = row['statut'];
          return statut is String && reservationStatutAllowsChat(statut);
        },
      );

  Future<Map<String, _PeerInboxInfo>> _clientPeerInfoById(
    List<String> clientIds,
  ) async {
    if (clientIds.isEmpty) return {};

    final response = await _client
        .from('client_profiles')
        .select('id, user_id')
        .inFilter('id', clientIds);

    final userIdByClient = <String, String>{};
    for (final raw in response as List<dynamic>) {
      final m = Map<String, dynamic>.from(raw as Map);
      userIdByClient[m['id'] as String] = m['user_id'] as String;
    }

    final userIds = userIdByClient.values.toList();
    final profiles = await _profileService.getByUserIds(userIds);
    final lastSeenByUser = await _profileService.lastSeenByUserIds(userIds);

    return {
      for (final id in clientIds)
        id: () {
          final userId = userIdByClient[id];
          final p = userId != null ? profiles[userId] : null;
          final parts =
              [p?.prenom, p?.nom].whereType<String>().map((s) => s.trim());
          final name = parts.where((s) => s.isNotEmpty).join(' ');
          return _PeerInboxInfo(
            displayName: name.isNotEmpty ? name : DiscPrestaDash.unknownClient,
            prenom: p?.prenom?.trim(),
            nom: p?.nom?.trim(),
            avatarUrl: _normalizeAvatarUrl(p?.avatarUrl),
            lastSeenAt: userId != null ? lastSeenByUser[userId] : null,
          );
        }(),
    };
  }

  String? _normalizeAvatarUrl(String? url) {
    final trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  Future<int> countUnreadForClient(
    String clientProfileId,
    String currentUserId,
  ) =>
      _messageService.countUnreadForUser(
        userId: currentUserId,
        role: MessagingParticipantRole.client,
        profileId: clientProfileId,
      );

  Future<int> countUnreadForPrestataire(
    String prestataireProfileId,
    String currentUserId,
  ) =>
      _messageService.countUnreadForUser(
        userId: currentUserId,
        role: MessagingParticipantRole.prestataire,
        profileId: prestataireProfileId,
      );
}

class _ReservationMeta {
  const _ReservationMeta({this.dateHeure, this.serviceName});

  final DateTime? dateHeure;
  final String? serviceName;
}

class _PeerInboxInfo {
  const _PeerInboxInfo({
    required this.displayName,
    this.prenom,
    this.nom,
    this.avatarUrl,
    this.lastSeenAt,
  });

  final String displayName;
  final String? prenom;
  final String? nom;
  final String? avatarUrl;
  final DateTime? lastSeenAt;
}


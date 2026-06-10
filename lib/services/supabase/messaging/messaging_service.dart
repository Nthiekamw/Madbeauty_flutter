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

  Future<Conversation?> getByBookingId(String bookingId) =>
      SupabaseErrorHandler.run(
        operation: 'messaging.getByBookingId',
        action: () async {
          final row = await _client
              .from('conversations')
              .select()
              .eq('reservation_id', bookingId)
              .maybeSingle();
          if (row == null) return null;
          return SupabaseDomainCodec.conversation(
            Map<String, dynamic>.from(row),
          );
        },
      );

  /// En-tête chat (nom + avatar interlocuteur) même hors liste inbox.
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

          final lastByBooking =
              await _messageService.latestMessageByBookingIds([bookingId]);
          final unreadByBooking = await _messageService.unreadCountByBookingIds(
            [bookingId],
            currentUserId: currentUserId,
          );
          final reservationMeta = await _reservationMetaById([bookingId]);

          final peerId =
              peerIsPrestataire ? conv.prestataireId : conv.clientId;
          final peerInfo = peerIsPrestataire
              ? await _prestatairePeerInfoById([peerId])
              : await _clientPeerInfoById([peerId]);

          return _toInboxItem(
            conv: conv,
            currentUserId: currentUserId,
            peer: peerInfo[peerId],
            peerIsPrestataire: peerIsPrestataire,
            last: lastByBooking[bookingId],
            unread: unreadByBooking[bookingId] ?? 0,
            reservation: reservationMeta[bookingId],
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
          final convRows = await _client
              .from('conversations')
              .select()
              .eq(column, profileId)
              .order('last_message_at', ascending: false);

          final conversations = (convRows as List<dynamic>)
              .map(
                (r) => SupabaseDomainCodec.conversation(
                  Map<String, dynamic>.from(r as Map),
                ),
              )
              .toList();

          if (conversations.isEmpty) return [];

          final bookingIds =
              conversations.map((c) => c.reservationId).toList();

          final lastByBooking =
              await _messageService.latestMessageByBookingIds(bookingIds);
          final unreadByBooking = await _messageService.unreadCountByBookingIds(
            bookingIds,
            currentUserId: currentUserId,
          );

          final reservationMeta =
              await _reservationMetaById(bookingIds);

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
                last: lastByBooking[conv.reservationId],
                unread: unreadByBooking[conv.reservationId] ?? 0,
                reservation: reservationMeta[conv.reservationId],
              ),
          ];
        },
      );

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
      peerPrenom: peer?.prenom,
      peerNom: peer?.nom,
      peerAvatarUrl: peer?.avatarUrl,
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

    for (final raw in response as List<dynamic>) {
      final m = Map<String, dynamic>.from(raw as Map);
      final id = m['id'] as String;
      final salon = (m['nom_salon'] as String?)?.trim();
      final affiche = (m['nom_affiche'] as String?)?.trim();
      if (affiche != null && affiche.isNotEmpty) {
        labelByPresta[id] = affiche;
      } else if (salon != null && salon.isNotEmpty) {
        labelByPresta[id] = salon;
      }
      final uid = m['user_id'] as String?;
      if (uid != null) userIds.add(uid);
    }

    final profiles = await _profileService.getByUserIds(userIds);
    final avatarByPresta = <String, String?>{};

    for (final raw in response as List<dynamic>) {
      final m = Map<String, dynamic>.from(raw as Map);
      final id = m['id'] as String;
      final uid = m['user_id'] as String?;
      final p = uid != null ? profiles[uid] : null;

      if (!labelByPresta.containsKey(id)) {
        final parts =
            [p?.prenom, p?.nom].whereType<String>().map((s) => s.trim());
        final name = parts.where((s) => s.isNotEmpty).join(' ');
        if (name.isNotEmpty) labelByPresta[id] = name;
      }

      avatarByPresta[id] = _normalizeAvatarUrl(p?.avatarUrl);
    }

    final prenomByPresta = <String, String?>{};
    final nomByPresta = <String, String?>{};
    for (final raw in response as List<dynamic>) {
      final m = Map<String, dynamic>.from(raw as Map);
      final id = m['id'] as String;
      final uid = m['user_id'] as String?;
      final p = uid != null ? profiles[uid] : null;
      prenomByPresta[id] = p?.prenom?.trim();
      nomByPresta[id] = p?.nom?.trim();
    }

    return {
      for (final id in prestataireIds)
        id: _PeerInboxInfo(
          displayName: labelByPresta[id] ?? DiscBk.unknownPresta,
          prenom: prenomByPresta[id],
          nom: nomByPresta[id],
          avatarUrl: avatarByPresta[id],
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
          return ClientPrestaChatAccess.noBooking();
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

    final profiles =
        await _profileService.getByUserIds(userIdByClient.values.toList());

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
  });

  final String displayName;
  final String? prenom;
  final String? nom;
  final String? avatarUrl;
}


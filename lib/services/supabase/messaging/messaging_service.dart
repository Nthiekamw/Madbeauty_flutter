import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/messaging/conversation.dart';
import '../../../core/models/domain/messaging/message.dart';
import '../../../core/models/domain/serialization/supabase_domain_codec.dart';
import '../../../features/messaging/models/conversation_inbox_item.dart';
import '../profile/profile_service.dart';
import 'message_service.dart';

/// Inbox enrichie (noms, réservation) — s'appuie sur [MessageService] pour les messages.
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

          final peerNames = peerIsPrestataire
              ? await _prestataireDisplayNames(peerIds)
              : await _clientDisplayNames(peerIds);

          return [
            for (final conv in conversations)
              _toInboxItem(
                conv: conv,
                currentUserId: currentUserId,
                peerName: peerNames[peerIsPrestataire
                    ? conv.prestataireId
                    : conv.clientId],
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
    required String? peerName,
    required Message? last,
    required int unread,
    required _ReservationMeta? reservation,
  }) {
    return ConversationInboxItem(
      conversation: conv,
      peerDisplayName: peerName?.trim().isNotEmpty == true
          ? peerName!.trim()
          : 'MadBeauty',
      lastMessagePreview: last?.content,
      lastMessageAt: last?.createdAt ?? conv.lastMessageAt,
      unreadCount: unread,
      reservationDate: reservation?.dateHeure,
      serviceName: reservation?.serviceName,
      isLastMessageMine: last?.senderId == currentUserId,
    );
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

  Future<Map<String, String>> _prestataireDisplayNames(
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
    for (final raw in response as List<dynamic>) {
      final m = Map<String, dynamic>.from(raw as Map);
      final id = m['id'] as String;
      if (labelByPresta.containsKey(id)) continue;
      final uid = m['user_id'] as String?;
      final p = uid != null ? profiles[uid] : null;
      final parts = [p?.prenom, p?.nom].whereType<String>().map((s) => s.trim());
      final name = parts.where((s) => s.isNotEmpty).join(' ');
      if (name.isNotEmpty) labelByPresta[id] = name;
    }

    return labelByPresta;
  }

  Future<Map<String, String>> _clientDisplayNames(
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
      for (final entry in userIdByClient.entries)
        entry.key: () {
          final p = profiles[entry.value];
          final parts =
              [p?.prenom, p?.nom].whereType<String>().map((s) => s.trim());
          final name = parts.where((s) => s.isNotEmpty).join(' ');
          return name.isNotEmpty ? name : 'Cliente';
        }(),
    };
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

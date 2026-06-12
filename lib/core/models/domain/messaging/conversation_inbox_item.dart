import 'package:madbeauty/core/models/domain/messaging/conversation.dart';

/// Ligne inbox : conversation + contexte réservation et interlocuteur.
class ConversationInboxItem {
  const ConversationInboxItem({
    required this.conversation,
    required this.peerDisplayName,
    this.peerPrenom,
    this.peerNom,
    this.peerAvatarUrl,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.reservationDate,
    this.serviceName,
    this.isLastMessageMine = false,
    this.isLastMessageReadByPeer = true,
    this.peerLastSeenAt,
    this.showSalonName = false,
  });

  final Conversation conversation;
  final String peerDisplayName;
  final String? peerPrenom;
  final String? peerNom;
  final String? peerAvatarUrl;
  final DateTime? peerLastSeenAt;
  /// Côté cliente : afficher le salon plutôt que le nom du pro.
  final bool showSalonName;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime? reservationDate;
  final String? serviceName;
  final bool isLastMessageMine;
  final bool isLastMessageReadByPeer;

  bool get hasUnread => unreadCount > 0;

  /// Dernier message envoyé par moi, pas encore lu par l’interlocuteur.
  bool get isOutgoingUnread =>
      isLastMessageMine && !isLastMessageReadByPeer;

  bool get hasConversationActivity =>
      (lastMessagePreview?.trim().isNotEmpty ?? false) || lastMessageAt != null;
}

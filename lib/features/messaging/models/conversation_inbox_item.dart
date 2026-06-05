import '../../../core/models/domain/messaging/conversation.dart';

/// Ligne inbox : conversation + contexte réservation et interlocuteur.
class ConversationInboxItem {
  const ConversationInboxItem({
    required this.conversation,
    required this.peerDisplayName,
    this.peerAvatarUrl,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.reservationDate,
    this.serviceName,
    this.isLastMessageMine = false,
  });

  final Conversation conversation;
  final String peerDisplayName;
  final String? peerAvatarUrl;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime? reservationDate;
  final String? serviceName;
  final bool isLastMessageMine;

  bool get hasUnread => unreadCount > 0;

  bool get hasConversationActivity =>
      (lastMessagePreview?.trim().isNotEmpty ?? false) || lastMessageAt != null;
}


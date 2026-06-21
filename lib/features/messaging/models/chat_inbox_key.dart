import 'messaging_inbox_role.dart';

/// Clé d’écran chat : fil (conversation) ou réservation legacy (deep link / push).
class ChatRouteKey {
  const ChatRouteKey({
    this.conversationId,
    this.bookingId,
    this.viewerRole,
  }) : assert(
          conversationId != null || bookingId != null,
          'conversationId ou bookingId requis',
        );

  final String? conversationId;
  final String? bookingId;
  final MessagingInboxRole? viewerRole;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatRouteKey &&
          conversationId == other.conversationId &&
          bookingId == other.bookingId &&
          viewerRole == other.viewerRole;

  @override
  int get hashCode => Object.hash(conversationId, bookingId, viewerRole);
}

/// Clé provider en-tête chat.
typedef ChatInboxKey = ChatRouteKey;

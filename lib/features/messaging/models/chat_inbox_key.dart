import 'messaging_inbox_role.dart';

/// Clé provider en-tête chat : réservation + rôle de l'utilisateur dans le fil.
class ChatInboxKey {
  const ChatInboxKey({required this.bookingId, this.viewerRole});

  final String bookingId;
  final MessagingInboxRole? viewerRole;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatInboxKey &&
          bookingId == other.bookingId &&
          viewerRole == other.viewerRole;

  @override
  int get hashCode => Object.hash(bookingId, viewerRole);
}

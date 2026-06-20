import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/messaging/conversation_inbox_item.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../prestataire/providers/profile/current_prestataire_provider.dart';
import '../../../services/supabase/messaging/messaging_service.dart';
import '../../../services/supabase/messaging/messaging_service_core_providers.dart';
import '../../../services/supabase/profile/client_profile_providers.dart';
import '../models/chat_inbox_key.dart';
import '../models/messaging_inbox_role.dart';
import 'messaging_refresh_signal_provider.dart';

export '../models/messaging_inbox_role.dart';

final conversationsInboxProvider = FutureProvider.autoDispose
    .family<List<ConversationInboxItem>, MessagingInboxRole>((ref, role) async {
  ref.watch(messagingRefreshSignalProvider);
  final service = ref.watch(messagingServiceProvider);
  final user = switch (ref.watch(authNotifierProvider)) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (service == null || user == null) return [];

  switch (role) {
    case MessagingInboxRole.client:
      final client = await ref.watch(currentClientProfileProvider.future);
      if (client == null) return [];
      return service.listInboxForClient(client.id, user.id);
    case MessagingInboxRole.prestataire:
      final presta = await ref.watch(currentPrestataireProvider.future);
      if (presta == null) return [];
      return service.listInboxForPrestataire(presta.id, user.id);
  }
});

/// Total messages non lus (badge onglet + en-tête inbox). Conservé hors autoDispose.
final messagingUnreadCountProvider =
    FutureProvider.family<int, MessagingInboxRole>((ref, role) async {
  ref.watch(messagingRefreshSignalProvider);
  ref.listen(authNotifierProvider, (_, __) {
    ref.invalidateSelf();
  });
  final service = ref.watch(messagingServiceProvider);
  final user = switch (ref.watch(authNotifierProvider)) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (service == null || user == null) return 0;

  switch (role) {
    case MessagingInboxRole.client:
      final client = await ref.watch(currentClientProfileProvider.future);
      if (client == null) return 0;
      return service.countUnreadForClient(client.id, user.id);
    case MessagingInboxRole.prestataire:
      final presta = await ref.watch(currentPrestataireProvider.future);
      if (presta == null) return 0;
      return service.countUnreadForPrestataire(presta.id, user.id);
  }
});

final chatInboxItemProvider = FutureProvider.autoDispose
    .family<ConversationInboxItem?, ChatInboxKey>((ref, key) async {
  final bookingId = key.bookingId;
  final service = ref.watch(messagingServiceProvider);
  final user = switch (ref.watch(authNotifierProvider)) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (service == null || user == null) return null;

  final explicitRole = key.viewerRole;
  if (explicitRole != null) {
    return _resolveChatInboxItem(
      ref: ref,
      service: service,
      bookingId: bookingId,
      userId: user.id,
      viewerRole: explicitRole,
    );
  }

  final conv = await service.getByBookingId(bookingId);
  if (conv == null) return null;

  final client = await ref.watch(currentClientProfileProvider.future);
  final presta = await ref.watch(currentPrestataireProvider.future);

  final viewingAsClient =
      client != null && conv.clientId == client.id;
  final viewingAsPresta =
      presta != null && conv.prestataireId == presta.id;

  if (viewingAsClient && !viewingAsPresta) {
    return _resolveChatInboxItem(
      ref: ref,
      service: service,
      bookingId: bookingId,
      userId: user.id,
      viewerRole: MessagingInboxRole.client,
    );
  }

  if (viewingAsPresta && !viewingAsClient) {
    return _resolveChatInboxItem(
      ref: ref,
      service: service,
      bookingId: bookingId,
      userId: user.id,
      viewerRole: MessagingInboxRole.prestataire,
    );
  }

  if (viewingAsClient) {
    return _resolveChatInboxItem(
      ref: ref,
      service: service,
      bookingId: bookingId,
      userId: user.id,
      viewerRole: MessagingInboxRole.client,
    );
  }

  if (viewingAsPresta) {
    return _resolveChatInboxItem(
      ref: ref,
      service: service,
      bookingId: bookingId,
      userId: user.id,
      viewerRole: MessagingInboxRole.prestataire,
    );
  }

  return null;
});

Future<ConversationInboxItem?> _resolveChatInboxItem({
  required Ref ref,
  required MessagingService service,
  required String bookingId,
  required String userId,
  required MessagingInboxRole viewerRole,
}) async {
  final inboxRole = viewerRole;
  final peerIsPrestataire = viewerRole == MessagingInboxRole.client;

  final items = await ref.watch(conversationsInboxProvider(inboxRole).future);
  for (final item in items) {
    if (item.conversation.reservationId == bookingId) return item;
  }

  return service.resolveInboxItemForBooking(
    bookingId: bookingId,
    currentUserId: userId,
    peerIsPrestataire: peerIsPrestataire,
  );
}

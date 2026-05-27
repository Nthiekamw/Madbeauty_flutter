import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../features/messaging/models/conversation_inbox_item.dart';
import '../../../features/auth/providers/auth_notifier.dart';
import '../profile/client_profile_providers.dart';
import '../profile/profile_providers.dart';
import '../supabase_service.dart';
import '../../../features/prestataire/providers/current_prestataire_provider.dart';
import 'message_service.dart';
import 'messaging_service.dart';

final messageServiceProvider = Provider<MessageService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return MessageService(SupabaseService.client);
});

final messagingServiceProvider = Provider<MessagingService?>((ref) {
  final messageService = ref.watch(messageServiceProvider);
  final profileService = ref.watch(profileServiceProvider);
  if (messageService == null || profileService == null) return null;
  return MessagingService(
    SupabaseService.client,
    messageService: messageService,
    profileService: profileService,
  );
});

enum MessagingInboxRole { client, prestataire }

final conversationsInboxProvider = FutureProvider.autoDispose
    .family<List<ConversationInboxItem>, MessagingInboxRole>((ref, role) async {
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
    .family<ConversationInboxItem?, String>((ref, bookingId) async {
  final client = await ref.watch(currentClientProfileProvider.future);
  if (client != null) {
    final items = await ref.watch(
      conversationsInboxProvider(MessagingInboxRole.client).future,
    );
    for (final item in items) {
      if (item.conversation.reservationId == bookingId) return item;
    }
  }

  final presta = await ref.watch(currentPrestataireProvider.future);
  if (presta != null) {
    final items = await ref.watch(
      conversationsInboxProvider(MessagingInboxRole.prestataire).future,
    );
    for (final item in items) {
      if (item.conversation.reservationId == bookingId) return item;
    }
  }

  return null;
});

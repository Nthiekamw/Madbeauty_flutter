import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/messaging/message.dart';
import '../../../services/supabase/messaging/messaging_providers.dart';
import '../models/chat_inbox_key.dart';

/// Résout l’identifiant du fil (depuis conversationId ou bookingId legacy).
final chatConversationIdProvider = FutureProvider.autoDispose
    .family<String, ChatRouteKey>((ref, key) async {
  if (key.conversationId != null && key.conversationId!.isNotEmpty) {
    return key.conversationId!;
  }
  final service = ref.watch(messageServiceProvider);
  if (service == null) {
    throw StateError('Service messagerie indisponible.');
  }
  final conv = await service.ensureThreadForBooking(key.bookingId!);
  return conv.id;
});

/// Flux Realtime des messages d’un fil ([conversationId]).
final messagesProvider = StreamProvider.autoDispose
    .family<List<Message>, String>((ref, conversationId) {
  final service = ref.watch(messageServiceProvider);
  if (service == null) return const Stream.empty();
  return service.getMessages(conversationId);
});

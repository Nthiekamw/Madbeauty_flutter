import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/messaging/message.dart';
import '../../../services/supabase/messaging/messaging_providers.dart';

/// Flux Realtime des messages d'une réservation ([bookingId]).
///
/// Utiliser `ref.watch(messagesProvider(bookingId))` dans l'écran chat.
final messagesProvider = StreamProvider.autoDispose
    .family<List<Message>, String>((ref, bookingId) {
  final service = ref.watch(messageServiceProvider);
  if (service == null) return const Stream.empty();
  return service.getMessages(bookingId);
});

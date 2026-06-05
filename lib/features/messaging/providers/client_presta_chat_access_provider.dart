import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/messaging/messaging_providers.dart';
import '../../../services/supabase/profile/client_profile_providers.dart';
import '../models/client_presta_chat_access.dart';

/// Messagerie possible avec un prestataire (fiche publique).
final clientPrestaChatAccessProvider = FutureProvider.autoDispose
    .family<ClientPrestaChatAccess, String>((ref, prestataireId) async {
  final messaging = ref.watch(messagingServiceProvider);
  final client = await ref.watch(currentClientProfileProvider.future);
  if (messaging == null || client == null) {
    return ClientPrestaChatAccess.noBooking();
  }
  return messaging.resolveClientChatAccess(
    clientProfileId: client.id,
    prestataireId: prestataireId,
  );
});


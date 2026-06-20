import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/domain/user_support_message.dart';
import '../../../features/auth/providers/auth_notifier.dart';
import '../supabase_service.dart';
import 'user_support_message_service.dart';
import 'user_support_service.dart';

final userSupportServiceProvider = Provider<UserSupportService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return UserSupportService.fromEnv();
});

final myUserSupportThreadIdProvider = FutureProvider.autoDispose<String>((ref) async {
  final service = ref.watch(userSupportServiceProvider);
  if (service == null) {
    throw StateError('Supabase indisponible');
  }
  return service.ensureMyThread();
});

final userSupportMessageServiceProvider =
    Provider<UserSupportMessageService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return UserSupportMessageService(SupabaseService.client);
});

final userSupportMessagesProvider = StreamProvider.autoDispose
    .family<List<UserSupportMessage>, String>((ref, threadId) {
  final service = ref.watch(userSupportMessageServiceProvider);
  if (service == null) return const Stream.empty();
  return service.watchMessages(threadId);
});

/// Messages admin non lus dans le fil support de l'utilisateur connecté.
final userSupportUnreadCountProvider = Provider.autoDispose<int>((ref) {
  if (!AppConfig.hasSupabase) return 0;

  final userId = ref.watch(authNotifierProvider).value?.id;
  if (userId == null) return 0;

  final threadId = ref.watch(
    myUserSupportThreadIdProvider.select((async) => async.value),
  );
  if (threadId == null) return 0;

  final messagesAsync = ref.watch(userSupportMessagesProvider(threadId));
  return messagesAsync.when(
    data: (messages) =>
        messages.where((m) => m.senderId != userId && !m.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/domain/user_support_message.dart';
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

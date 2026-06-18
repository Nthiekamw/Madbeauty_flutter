import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/admin/admin_user_support_thread.dart';
import '../../../services/supabase/admin/admin_user_support_service.dart';

final adminUserSupportServiceProvider =
    Provider<AdminUserSupportService?>((ref) {
  return AdminUserSupportService.fromEnv();
});

final adminUserSupportThreadsProvider =
    FutureProvider.autoDispose<List<AdminUserSupportThread>>((ref) async {
  final service = ref.watch(adminUserSupportServiceProvider);
  if (service == null) return const [];
  return service.listThreads();
});

final adminUserSupportUnreadCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final threads = await ref.watch(adminUserSupportThreadsProvider.future);
  return threads.fold<int>(0, (sum, t) => sum + t.unreadCount);
});

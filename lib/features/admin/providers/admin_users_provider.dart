import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/admin/admin_users_service.dart';
import '../models/admin_user_summary.dart';

final adminUsersServiceProvider = Provider<AdminUsersService?>((ref) {
  return AdminUsersService.fromEnv();
});

final adminUsersSearchProvider = FutureProvider.autoDispose
    .family<List<AdminUserSummary>, String>((ref, query) async {
  final service = ref.watch(adminUsersServiceProvider);
  if (service == null) return const [];
  return service.searchUsers(query: query);
});

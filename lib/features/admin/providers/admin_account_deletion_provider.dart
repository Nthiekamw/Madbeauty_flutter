import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/admin/admin_account_deletion_request.dart';
import '../../../services/supabase/admin/admin_account_deletion_service.dart';

final adminAccountDeletionServiceProvider =
    Provider<AdminAccountDeletionService?>((ref) {
  return AdminAccountDeletionService.fromEnv();
});

final adminAccountDeletionRequestsProvider =
    FutureProvider.autoDispose<List<AdminAccountDeletionRequest>>((ref) async {
  final service = ref.watch(adminAccountDeletionServiceProvider);
  if (service == null) return const [];
  return service.listPendingRequests();
});

final adminPendingAccountDeletionsCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final items = await ref.watch(adminAccountDeletionRequestsProvider.future);
  return items.length;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/admin/admin_audit_service.dart';
import '../models/admin_audit_entry.dart';

final adminAuditServiceProvider = Provider<AdminAuditService?>((ref) {
  return AdminAuditService.fromEnv();
});

final adminAuditLogProvider =
    FutureProvider.autoDispose<List<AdminAuditEntry>>((ref) async {
  final service = ref.watch(adminAuditServiceProvider);
  if (service == null) return const [];
  return service.listAuditLog();
});

final adminVerificationEventsProvider =
    FutureProvider.autoDispose<List<AdminVerificationEvent>>((ref) async {
  final service = ref.watch(adminAuditServiceProvider);
  if (service == null) return const [];
  return service.listVerificationEvents();
});

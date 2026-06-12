import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/admin/admin_bug_report.dart';
import '../../../services/supabase/admin/admin_bug_reports_service.dart';

enum AdminBugReportFilter { pending, all }

final adminBugReportsServiceProvider = Provider<AdminBugReportsService?>((ref) {
  return AdminBugReportsService.fromEnv();
});

final adminBugReportsProvider = FutureProvider.autoDispose
    .family<List<AdminBugReport>, AdminBugReportFilter>((ref, filter) async {
      final service = ref.watch(adminBugReportsServiceProvider);
      if (service == null) return const [];
      return service.listReports(
        onlyPending: filter == AdminBugReportFilter.pending,
      );
    });

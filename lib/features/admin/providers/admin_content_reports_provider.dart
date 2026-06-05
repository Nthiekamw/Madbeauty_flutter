import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/admin/admin_content_reports_service.dart';
import '../models/admin_content_report.dart';

enum AdminContentReportFilter { pending, all }

final adminContentReportsServiceProvider =
    Provider<AdminContentReportsService?>((ref) {
      return AdminContentReportsService.fromEnv();
    });

final adminContentReportsProvider = FutureProvider.autoDispose
    .family<List<AdminContentReport>, AdminContentReportFilter>((
      ref,
      filter,
    ) async {
      final service = ref.watch(adminContentReportsServiceProvider);
      if (service == null) return const [];
      return service.listReports(
        onlyPending: filter == AdminContentReportFilter.pending,
      );
    });

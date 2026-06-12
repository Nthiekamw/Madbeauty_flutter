import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/admin/admin_bug_report.dart';
import '../supabase_service.dart';

class AdminBugReportsService {
  AdminBugReportsService(this._client);

  final SupabaseClient _client;

  factory AdminBugReportsService.fromEnv() =>
      AdminBugReportsService(SupabaseService.client);

  Future<List<AdminBugReport>> listReports({
    bool onlyPending = true,
    int limit = 100,
  }) async {
    return SupabaseErrorHandler.run(
      operation: 'adminBugReports.listReports',
      action: () async {
        final rows = await _client.rpc(
          'admin_list_bug_reports',
          params: {
            'p_only_pending': onlyPending,
            'p_limit': limit,
          },
        );
        final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
        if (list.isEmpty) return const [];
        return list.map(_mapRow).toList();
      },
    );
  }

  Future<void> updateReport({
    required String reportId,
    required String status,
    String? adminNotes,
    String? reporterMessage,
  }) async {
    await SupabaseErrorHandler.run(
      operation: 'adminBugReports.updateReport',
      action: () async {
        await _client.rpc(
          'admin_update_bug_report',
          params: {
            'p_report_id': reportId,
            'p_status': status,
            'p_admin_notes': adminNotes,
            'p_reporter_message': reporterMessage,
          },
        );
      },
    );
  }

  AdminBugReport _mapRow(Map<String, dynamic> row) {
    return AdminBugReport(
      id: row['id'] as String? ?? '',
      reporterUserId: row['reporter_user_id'] as String? ?? '',
      reporterEmail: row['reporter_email'] as String?,
      reporterDisplayName: row['reporter_display_name'] as String?,
      title: row['title'] as String? ?? '',
      category: row['category'] as String? ?? 'other',
      description: row['description'] as String? ?? '',
      stepsToReproduce: row['steps_to_reproduce'] as String?,
      appVersion: row['app_version'] as String?,
      platform: row['platform'] as String?,
      deviceInfo: row['device_info'] as String?,
      currentScreen: row['current_screen'] as String?,
      screenshotUrl: row['screenshot_url'] as String?,
      status: row['status'] as String? ?? 'pending',
      adminNotes: row['admin_notes'] as String?,
      reporterMessage: row['reporter_message'] as String?,
      createdAt:
          DateTime.tryParse((row['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse((row['updated_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      resolvedAt: DateTime.tryParse((row['resolved_at'] as String?) ?? ''),
    );
  }
}

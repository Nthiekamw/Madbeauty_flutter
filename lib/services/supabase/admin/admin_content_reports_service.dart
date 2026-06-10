import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/admin/admin_content_report.dart';
import '../supabase_service.dart';

class AdminContentReportsService {
  AdminContentReportsService(this._client);

  final SupabaseClient _client;

  factory AdminContentReportsService.fromEnv() =>
      AdminContentReportsService(SupabaseService.client);

  Future<List<AdminContentReport>> listReports({
    bool onlyPending = true,
    int limit = 100,
  }) async {
    return SupabaseErrorHandler.run(
      operation: 'adminContentReports.listReports',
      action: () async {
        final rows = await _client.rpc(
          'admin_list_content_reports',
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

  Future<void> markReviewed({required String reportId}) async {
    await moderateReport(
      reportId: reportId,
      action: 'dismiss',
    );
  }

  Future<void> moderateReport({
    required String reportId,
    required String action,
    String? note,
  }) async {
    await SupabaseErrorHandler.run(
      operation: 'adminContentReports.moderateReport',
      action: () async {
        await _client.rpc(
          'admin_moderate_content_report',
          params: {
            'p_report_id': reportId,
            'p_action': action,
            'p_note': note,
          },
        );
      },
    );
  }

  AdminContentReport _mapRow(Map<String, dynamic> row) {
    return AdminContentReport(
      id: row['id'] as String? ?? '',
      reporterUserId: row['reporter_user_id'] as String? ?? '',
      reporterEmail: row['reporter_email'] as String?,
      reporterDisplayName: row['reporter_display_name'] as String?,
      targetType: row['target_type'] as String? ?? '',
      targetId: row['target_id'] as String? ?? '',
      targetLabel: row['target_label'] as String?,
      reason: row['reason'] as String? ?? '',
      details: row['details'] as String?,
      createdAt:
          DateTime.tryParse((row['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      reviewedAt: DateTime.tryParse((row['reviewed_at'] as String?) ?? ''),
      actionTaken: row['action_taken'] as String?,
      actionNote: row['action_note'] as String?,
    );
  }
}

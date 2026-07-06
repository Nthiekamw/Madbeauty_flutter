import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/bug_report.dart';
import '../../../core/models/domain/bug_report_chat_summary.dart';
import '../../../core/utils/safe_broadcast_stream.dart';

enum BugReportCategory {
  auth('auth'),
  booking('booking'),
  payment('payment'),
  messaging('messaging'),
  profile('profile'),
  other('other');

  const BugReportCategory(this.value);
  final String value;
}

class BugReportService {
  BugReportService(this._client);

  final SupabaseClient _client;

  Future<String> submit({
    required BugReportCategory category,
    required String title,
    required String description,
    String? stepsToReproduce,
    String? appVersion,
    String? platform,
    String? deviceInfo,
    String? currentScreen,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'bugReport.submit',
        action: () async {
          final userId =
              _client.auth.currentUser?.id ?? _client.auth.currentSession?.user.id;
          if (userId == null) {
            throw StateError('Utilisateur non connecté');
          }
          final inserted = await _client
              .from('bug_reports')
              .insert({
                'reporter_user_id': userId,
                'category': category.value,
                'title': title.trim(),
                'description': description.trim(),
                if (stepsToReproduce != null &&
                    stepsToReproduce.trim().isNotEmpty)
                  'steps_to_reproduce': stepsToReproduce.trim(),
                if (appVersion != null && appVersion.trim().isNotEmpty)
                  'app_version': appVersion.trim(),
                if (platform != null && platform.trim().isNotEmpty)
                  'platform': platform.trim(),
                if (deviceInfo != null && deviceInfo.trim().isNotEmpty)
                  'device_info': deviceInfo.trim(),
                if (currentScreen != null && currentScreen.trim().isNotEmpty)
                  'current_screen': currentScreen.trim(),
              })
              .select('id')
              .single();
          return inserted['id'] as String;
        },
      );

  Future<void> setScreenshotUrl({
    required String reportId,
    required String screenshotUrl,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'bugReport.setScreenshotUrl',
        action: () async {
          await _client.rpc(
            'set_bug_report_screenshot',
            params: {
              'p_report_id': reportId,
              'p_screenshot_url': screenshotUrl,
            },
          );
        },
      );

  Stream<BugReportChatSummary> watchChatSummary(String bugReportId) {
    final safe = SafeBroadcastStream<BugReportChatSummary>();
    StreamSubscription<List<Map<String, dynamic>>>? streamSub;

    Future<void> emitLatest() async {
      if (!safe.isActive) return;
      try {
        final summary = await getChatSummary(bugReportId);
        if (summary != null) safe.add(summary);
      } catch (e, st) {
        safe.addError(e, st);
      }
    }

    void startListening() {
      unawaited(() async {
        await emitLatest();
        if (!safe.isActive) return;

        streamSub = _client
            .from('bug_reports')
            .stream(primaryKey: ['id'])
            .eq('id', bugReportId)
            .listen(
              (rows) {
                if (!safe.isActive || rows.isEmpty) return;
                safe.add(BugReportChatSummary.fromRow(rows.first));
              },
              onError: safe.addError,
            );
      }());
    }

    safe.bind(
      onListen: startListening,
      cleanup: () async {
        await streamSub?.cancel();
        streamSub = null;
      },
    );

    return safe.stream;
  }

  Future<BugReportChatSummary?> getChatSummary(String bugReportId) async {
    return SupabaseErrorHandler.run(
      operation: 'bugReport.getChatSummary',
      action: () async {
        final row = await _client
            .from('bug_reports')
            .select('id, title, status')
            .eq('id', bugReportId)
            .maybeSingle();
        if (row == null) return null;
        return BugReportChatSummary.fromRow(row);
      },
    );
  }

  Future<List<BugReport>> listMine({int limit = 30}) async {
    return SupabaseErrorHandler.run(
      operation: 'bugReport.listMine',
      action: () async {
        final rows = await _client.rpc(
          'list_my_bug_reports',
          params: {'p_limit': limit},
        );
        final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
        return list.map(_mapMine).toList();
      },
    );
  }

  BugReport _mapMine(Map<String, dynamic> row) {
    return BugReport(
      id: row['id'] as String? ?? '',
      title: row['title'] as String? ?? '',
      category: row['category'] as String? ?? 'other',
      description: row['description'] as String? ?? '',
      stepsToReproduce: row['steps_to_reproduce'] as String?,
      status: row['status'] as String? ?? 'pending',
      reporterMessage: row['reporter_message'] as String?,
      screenshotUrl: row['screenshot_url'] as String?,
      appVersion: row['app_version'] as String?,
      platform: row['platform'] as String?,
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

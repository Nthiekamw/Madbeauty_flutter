import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/domain/bug_report.dart';
import '../../../core/models/domain/bug_report_chat_summary.dart';
import '../../../core/models/domain/bug_report_message.dart';
import '../supabase_service.dart';
import 'bug_report_message_service.dart';
import 'bug_report_service.dart';

final bugReportServiceProvider = Provider<BugReportService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return BugReportService(SupabaseService.client);
});

final myBugReportsProvider = FutureProvider.autoDispose<List<BugReport>>((ref) async {
  final service = ref.watch(bugReportServiceProvider);
  if (service == null) return const [];
  return service.listMine();
});

final bugReportMessageServiceProvider = Provider<BugReportMessageService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return BugReportMessageService(SupabaseService.client);
});

final bugReportMessagesProvider = StreamProvider.autoDispose
    .family<List<BugReportMessage>, String>((ref, bugReportId) {
  final service = ref.watch(bugReportMessageServiceProvider);
  if (service == null) return const Stream.empty();
  return service.watchMessages(bugReportId);
});

final bugReportChatSummaryProvider = StreamProvider.autoDispose
    .family<BugReportChatSummary, String>((ref, bugReportId) {
  final service = ref.watch(bugReportServiceProvider);
  if (service == null) return const Stream.empty();
  return service.watchChatSummary(bugReportId);
});

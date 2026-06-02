import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../supabase_service.dart';
import 'content_report_service.dart';

final contentReportServiceProvider = Provider<ContentReportService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return ContentReportService(SupabaseService.client);
});

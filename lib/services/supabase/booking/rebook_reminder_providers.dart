import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../supabase_service.dart';
import 'rebook_reminder_service.dart';

final rebookReminderServiceProvider = Provider<RebookReminderService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return RebookReminderService(SupabaseService.client);
});

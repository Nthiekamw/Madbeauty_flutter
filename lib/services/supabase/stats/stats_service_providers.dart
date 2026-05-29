import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../supabase_service.dart';
import 'stats_service.dart';

final statsServiceProvider = Provider<StatsService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return StatsService(SupabaseService.client);
});

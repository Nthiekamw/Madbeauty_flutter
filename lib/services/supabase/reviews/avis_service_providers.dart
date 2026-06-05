import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../supabase_service.dart';
import 'avis_service.dart';

final avisServiceProvider = Provider<AvisService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return AvisService(SupabaseService.client);
});


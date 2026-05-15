import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../supabase_service.dart';
import 'profile_service.dart';

final profileServiceProvider = Provider<ProfileService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return ProfileService(SupabaseService.client);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../supabase_service.dart';
import 'storage_service.dart';

final storageServiceProvider = Provider<StorageService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return StorageService(SupabaseService.client);
});

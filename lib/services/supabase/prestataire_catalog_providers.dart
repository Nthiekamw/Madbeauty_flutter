import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import 'prestataire_catalog_repository.dart';
import 'supabase_service.dart';

final prestataireCatalogRepositoryProvider =
    Provider<PrestataireCatalogRepository?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return PrestataireCatalogRepository(SupabaseService.client);
});

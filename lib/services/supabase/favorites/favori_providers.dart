import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../supabase_service.dart';
import 'favori_service.dart';

final favoriServiceProvider = Provider<FavoriService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return FavoriService(SupabaseService.client);
});


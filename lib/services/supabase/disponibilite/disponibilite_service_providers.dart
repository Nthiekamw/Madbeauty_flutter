import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../supabase_service.dart';
import 'disponibilite_service.dart';

final disponibiliteServiceProvider = Provider<DisponibiliteService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return DisponibiliteService(SupabaseService.client);
});


import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../supabase_service.dart';
import 'service_beaute_service.dart';

final serviceBeauteServiceProvider = Provider<ServiceBeauteService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return ServiceBeauteService(SupabaseService.client);
});


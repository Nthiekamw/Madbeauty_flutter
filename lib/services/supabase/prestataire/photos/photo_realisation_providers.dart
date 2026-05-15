import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../storage/storage_providers.dart';
import '../../supabase_service.dart';
import 'photo_realisation_service.dart';

final photoRealisationServiceProvider = Provider<PhotoRealisationService?>((
  ref,
) {
  if (!AppConfig.hasSupabase) return null;
  final storageService = ref.watch(storageServiceProvider);
  if (storageService == null) return null;
  return PhotoRealisationService(
    SupabaseService.client,
    storageService: storageService,
  );
});

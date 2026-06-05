import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../profile/profile_providers.dart';
import '../../supabase_service.dart';
import 'prestataire_service.dart';

final prestataireServiceProvider = Provider<PrestataireService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  final profileService = ref.watch(profileServiceProvider);
  if (profileService == null) return null;
  return PrestataireService(
    SupabaseService.client,
    profileService: profileService,
  );
});

final prestataireCatalogRepositoryProvider = prestataireServiceProvider;


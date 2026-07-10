import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../location/location_providers.dart';
import '../../../core/config/app_config.dart';
import '../../../core/models/domain/user/client_profile.dart';
import '../supabase_service.dart';
import 'client_profile_service.dart';

final clientProfileServiceProvider = Provider<ClientProfileService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return ClientProfileService(
    SupabaseService.client,
    geocoding: ref.watch(geocodingServiceProvider),
  );
});

final currentClientProfileProvider = FutureProvider<ClientProfile?>((ref) async {
  final service = ref.watch(clientProfileServiceProvider);
  final userId = SupabaseService.client.auth.currentUser?.id;
  if (service == null || userId == null) return null;
  return service.getByUserId(userId);
});


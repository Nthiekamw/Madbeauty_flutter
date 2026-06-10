import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../supabase_service.dart';
import 'prestataire_like_service.dart';

final prestataireLikeServiceProvider = Provider<PrestataireLikeService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return PrestataireLikeService(SupabaseService.client);
});

final prestataireLikesCountProvider = FutureProvider.autoDispose
    .family<int, String>((ref, prestataireId) async {
  final service = ref.watch(prestataireLikeServiceProvider);
  if (service == null) return 0;
  return service.countForPrestataire(prestataireId);
});

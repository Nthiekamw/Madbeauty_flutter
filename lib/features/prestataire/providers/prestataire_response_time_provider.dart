import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../services/supabase/supabase_service.dart';

/// Temps de réponse moyen en minutes (30 j), ou `null` si données insuffisantes.
final prestataireAvgResponseMinutesProvider = FutureProvider.autoDispose
    .family<int?, String>((ref, prestataireId) async {
      if (!AppConfig.hasSupabase) return null;
      final response = await SupabaseService.client.rpc(
        'get_prestataire_avg_response_minutes',
        params: {'p_prestataire_id': prestataireId},
      );
      if (response == null) return null;
      if (response is int) return response;
      if (response is num) return response.toInt();
      return null;
    });

/// Badge « répond rapidement » si moyenne ≤ 120 minutes.
final prestataireRespondsQuicklyProvider = FutureProvider.autoDispose
    .family<bool, String>((ref, prestataireId) async {
      final minutes =
          await ref.watch(prestataireAvgResponseMinutesProvider(prestataireId).future);
      return minutes != null && minutes <= 120;
    });

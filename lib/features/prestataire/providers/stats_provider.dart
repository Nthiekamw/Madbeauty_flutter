import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/stats/stats_prestataire.dart';
import '../../../services/supabase/stats/stats_service_providers.dart';
import 'prestataire_analytics_period_provider.dart';

/// Stats Supabase (`get_prestataire_stats`) pour un prestataire.
///
/// Recharge automatiquement quand la période analytique change.
final statsProvider = FutureProvider.autoDispose
    .family<StatsPrestataire, String>((ref, prestataireId) async {
  final service = ref.watch(statsServiceProvider);
  if (service == null) return StatsPrestataire.empty;

  final period = ref.watch(prestataireAnalyticsPeriodProvider);
  return service.getStats(
    prestataireId: prestataireId,
    period: period,
  );
});

void invalidatePrestataireStats(WidgetRef ref, String prestataireId) {
  ref.invalidate(statsProvider(prestataireId));
}

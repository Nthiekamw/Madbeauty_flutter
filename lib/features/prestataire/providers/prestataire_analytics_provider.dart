import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/stats_prestataire_mapper.dart';
import '../models/prestataire_analytics_data.dart';
import 'current_prestataire_provider.dart';
import 'stats_provider.dart';

final prestataireAnalyticsProvider =
    FutureProvider.autoDispose<PrestataireAnalyticsData>((ref) async {
  final presta = await ref.watch(currentPrestataireProvider.future);
  if (presta == null) return PrestataireAnalyticsData.empty;

  final stats = await ref.watch(statsProvider(presta.id).future);
  return stats.toAnalyticsData();
});


import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_country_reservation_stats.dart';
import 'admin_analytics_provider.dart';

final adminCountryStatsProvider =
    FutureProvider.autoDispose<List<AdminCountryReservationStats>>((ref) async {
  final service = ref.watch(adminAnalyticsServiceProvider);
  if (service == null) return const [];
  return service.getReservationsByCountry();
});

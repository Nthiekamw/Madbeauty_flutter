import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/admin/admin_analytics_service.dart';
import '../models/admin_analytics_summary.dart';

final adminAnalyticsServiceProvider = Provider<AdminAnalyticsService?>((ref) {
  return AdminAnalyticsService.fromEnv();
});

final adminAnalyticsProvider =
    FutureProvider.autoDispose<AdminAnalyticsSummary>((ref) async {
  final service = ref.watch(adminAnalyticsServiceProvider);
  if (service == null) {
    return const AdminAnalyticsSummary(
      usersTotal: 0,
      usersBanned: 0,
      clientsTotal: 0,
      prestatairesTotal: 0,
      prestatairesVerified: 0,
      verificationPending: 0,
      reportsPending: 0,
      reservationsTotal: 0,
      reservationsThisMonth: 0,
      revenueCapturedCents: 0,
      revenueThisMonthCents: 0,
    );
  }
  return service.getSummary();
});

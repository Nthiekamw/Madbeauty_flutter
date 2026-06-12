import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/admin/admin_analytics_summary.dart';
import '../supabase_service.dart';

class AdminAnalyticsService {
  AdminAnalyticsService(this._client);

  final SupabaseClient _client;

  factory AdminAnalyticsService.fromEnv() =>
      AdminAnalyticsService(SupabaseService.client);

  Future<AdminAnalyticsSummary> getSummary() async {
    return SupabaseErrorHandler.run(
      operation: 'adminAnalytics.getSummary',
      action: () async {
        final result = await _client.rpc('admin_get_analytics_summary');
        if (result is Map<String, dynamic>) {
          return AdminAnalyticsSummary.fromJson(result);
        }
        if (result is Map) {
          return AdminAnalyticsSummary.fromJson(
            Map<String, dynamic>.from(result),
          );
        }
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
      },
    );
  }
}

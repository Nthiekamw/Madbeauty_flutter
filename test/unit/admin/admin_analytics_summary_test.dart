import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/features/admin/models/admin_analytics_summary.dart';

void main() {
  test('AdminAnalyticsSummary.fromJson lit les compteurs', () {
    final summary = AdminAnalyticsSummary.fromJson({
      'users_total': 120,
      'users_banned': 2,
      'prestataires_total': 45,
      'prestataires_verified': 30,
      'verification_pending': 5,
      'reports_pending': 3,
      'reservations_total': 200,
      'reservations_this_month': 18,
      'revenue_captured_cents': 125000,
      'revenue_this_month_cents': 15000,
    });

    expect(summary.usersTotal, 120);
    expect(summary.usersBanned, 2);
    expect(summary.verificationPending, 5);
    expect(summary.revenueCapturedCents, 125000);
  });
}

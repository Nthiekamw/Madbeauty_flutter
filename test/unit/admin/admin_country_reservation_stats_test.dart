import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/features/admin/models/admin_country_reservation_stats.dart';

void main() {
  test('AdminCountryReservationStats.fromJson lit les compteurs par pays', () {
    final stats = AdminCountryReservationStats.fromJson({
      'country_code': 'fr',
      'reservations_total': 42,
      'reservations_this_month': 8,
      'prestataires_count': 12,
      'revenue_captured_cents': 9900,
    });

    expect(stats.countryCode, 'FR');
    expect(stats.reservationsTotal, 42);
    expect(stats.reservationsThisMonth, 8);
    expect(stats.prestatairesCount, 12);
    expect(stats.revenueCapturedCents, 9900);
  });
}

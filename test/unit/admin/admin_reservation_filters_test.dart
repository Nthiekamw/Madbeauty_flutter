import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/features/admin/models/admin_reservation_filters.dart';

void main() {
  test('copyWith efface les filtres optionnels', () {
    const initial = AdminReservationFilters(
      statut: 'confirmee',
      paymentStatus: 'captured',
      fromDate: null,
    );
    final cleared = initial.copyWith(clearStatut: true, clearPaymentStatus: true);
    expect(cleared.statut, isNull);
    expect(cleared.paymentStatus, isNull);
  });
}

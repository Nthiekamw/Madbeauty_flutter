import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/features/booking/logic/pending_booking_intent.dart';

void main() {
  test('bookingPath inclut les query params', () {
    const intent = PendingBookingIntent(
      prestataireId: '11111111-1111-1111-1111-111111111111',
      serviceId: '22222222-2222-2222-2222-222222222222',
      initialDay: '2026-07-15',
    );

    expect(
      intent.bookingPath,
      '/booking?prestataireId=11111111-1111-1111-1111-111111111111'
      '&serviceId=22222222-2222-2222-2222-222222222222'
      '&date=2026-07-15',
    );
  });

  test('bookingPath sans service ni date', () {
    const intent = PendingBookingIntent(
      prestataireId: '11111111-1111-1111-1111-111111111111',
    );

    expect(
      intent.bookingPath,
      '/booking?prestataireId=11111111-1111-1111-1111-111111111111',
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/features/booking/logic/reservation_chat_eligibility.dart';

void main() {
  group('reservationStatutAllowsChat', () {
    test('autorise confirmée et terminée', () {
      expect(reservationStatutAllowsChat('confirmee'), isTrue);
      expect(reservationStatutAllowsChat('done'), isTrue);
    });

    test('refuse en attente et annulée', () {
      expect(reservationStatutAllowsChat('en_attente'), isFalse);
      expect(reservationStatutAllowsChat('annulee'), isFalse);
    });
  });
}

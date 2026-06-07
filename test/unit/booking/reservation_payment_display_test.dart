import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/logic/booking/reservation_payment_display.dart';

void main() {
  test('acompte 20 % — lignes client et prestataire', () {
    final d = ReservationPaymentDisplay.fromFields(
      paymentMode: 'deposit_20',
      servicePriceCents: 5000,
      platformFeeCents: 100,
      prestataireAmountCents: 1000,
      amountCents: 1100,
      paymentStatus: 'authorized',
    );

    expect(d.modeLabel, contains('20'));
    expect(d.balanceOnSiteCents, 4000);
    expect(d.clientLines().any((l) => l.label.contains('sur place')), isTrue);
    expect(
      d.prestataireLines().any((l) => l.label.contains('Acompte')),
      isTrue,
    );
  });

  test('sur place + frais 1 €', () {
    final d = ReservationPaymentDisplay.fromFields(
      paymentMode: 'on_site',
      servicePriceCents: 5000,
      platformFeeCents: 100,
      amountCents: 100,
      paymentStatus: 'captured',
    );

    expect(d.balanceOnSiteCents, 5000);
    expect(d.clientLines().length >= 2, isTrue);
  });
}

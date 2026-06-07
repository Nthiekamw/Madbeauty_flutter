import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/logic/booking/booking_pricing.dart';

void main() {
  group('platformFeeCentsForPriorCount', () {
    test('gratuit pour les deux premières réservations', () {
      expect(platformFeeCentsForPriorCount(0), 0);
      expect(platformFeeCentsForPriorCount(1), 0);
    });

    test('1 € à partir de la 3e', () {
      expect(platformFeeCentsForPriorCount(2), 100);
      expect(platformFeeCentsForPriorCount(5), 100);
    });
  });

  group('computeBookingPricing', () {
    test('sur place sans frais — 1re résa', () {
      final b = computeBookingPricing(
        servicePriceEur: 50,
        paymentMode: BookingPaymentModeKind.onSite,
        priorBookingCount: 0,
        prestataireAcceptsConnect: true,
      );
      expect(b.requiresInAppPayment, isFalse);
      expect(b.totalChargeCents, 0);
      expect(b.balanceOnSiteCents, 5000);
    });

    test('sur place — 3e résa = 1 € seul', () {
      final b = computeBookingPricing(
        servicePriceEur: 50,
        paymentMode: BookingPaymentModeKind.onSite,
        priorBookingCount: 2,
        prestataireAcceptsConnect: false,
      );
      expect(b.requiresInAppPayment, isTrue);
      expect(b.totalChargeCents, 100);
      expect(b.prestatairePortionCents, 0);
      expect(b.isPlatformFeeOnly, isTrue);
    });

    test('acompte 20 % + frais — 3e résa', () {
      final b = computeBookingPricing(
        servicePriceEur: 50,
        paymentMode: BookingPaymentModeKind.deposit20,
        priorBookingCount: 2,
        prestataireAcceptsConnect: true,
      );
      expect(b.depositCents, 1000);
      expect(b.platformFeeCents, 100);
      expect(b.totalChargeCents, 1100);
      expect(b.balanceOnSiteCents, 4000);
    });

    test('acompte sans connect', () {
      expect(
        () => computeBookingPricing(
          servicePriceEur: 50,
          paymentMode: BookingPaymentModeKind.deposit20,
          priorBookingCount: 0,
          prestataireAcceptsConnect: false,
        ),
        throwsA(isA<BookingPricingException>()),
      );
    });

    test('remise parrainage −10 % sur prestation et acompte', () {
      final b = computeBookingPricing(
        servicePriceEur: 50,
        paymentMode: BookingPaymentModeKind.deposit20,
        priorBookingCount: 0,
        prestataireAcceptsConnect: true,
        referralDiscountPercent: 10,
      );
      expect(b.originalServicePriceCents, 5000);
      expect(b.servicePriceCents, 4500);
      expect(b.referralDiscountCents, 500);
      expect(b.depositCents, 900);
      expect(b.balanceOnSiteCents, 3600);
    });
  });
}

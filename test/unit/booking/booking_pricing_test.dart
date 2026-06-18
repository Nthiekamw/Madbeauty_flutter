import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/logic/booking/booking_pricing.dart';
import 'package:madbeauty/core/models/domain/booking/booking_platform_fee_settings.dart';

const _oneEuroFee = BookingPlatformFeeSettings(
  feeCents: 100,
  freeBookingCount: 2,
);

void main() {
  group('platformFeeCentsForPriorCount', () {
    test('gratuit sous le seuil admin', () {
      expect(platformFeeCentsForPriorCount(0, _oneEuroFee), 0);
      expect(platformFeeCentsForPriorCount(1, _oneEuroFee), 0);
    });

    test('frais à partir du seuil', () {
      expect(platformFeeCentsForPriorCount(2, _oneEuroFee), 100);
      expect(platformFeeCentsForPriorCount(5, _oneEuroFee), 100);
    });

    test('désactivé par défaut (0 centime)', () {
      expect(
        platformFeeCentsForPriorCount(10, BookingPlatformFeeSettings.defaults),
        0,
      );
    });
  });

  group('computeBookingPricing', () {
    test('sur place sans frais — défaut admin', () {
      final b = computeBookingPricing(
        servicePriceEur: 50,
        paymentMode: BookingPaymentModeKind.onSite,
        priorBookingCount: 5,
        prestataireAcceptsConnect: true,
      );
      expect(b.requiresInAppPayment, isFalse);
      expect(b.totalChargeCents, 0);
    });

    test('sur place — jamais de frais admin dans l’app', () {
      final b = computeBookingPricing(
        servicePriceEur: 50,
        paymentMode: BookingPaymentModeKind.onSite,
        priorBookingCount: 2,
        prestataireAcceptsConnect: false,
        platformFeeSettings: _oneEuroFee,
      );
      expect(b.requiresInAppPayment, isFalse);
      expect(b.totalChargeCents, 0);
      expect(b.platformFeeCents, 0);
    });

    test('acompte 20 % + frais admin', () {
      final b = computeBookingPricing(
        servicePriceEur: 50,
        paymentMode: BookingPaymentModeKind.deposit20,
        priorBookingCount: 2,
        prestataireAcceptsConnect: true,
        platformFeeSettings: _oneEuroFee,
      );
      expect(b.depositCents, 1000);
      expect(b.platformFeeCents, 100);
      expect(b.totalChargeCents, 1100);
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
  });
}

import 'package:madbeauty/core/config/pricing_config.dart';
import 'package:madbeauty/core/models/domain/booking/booking_platform_fee_settings.dart';

/// Mode de paiement de la prestation choisi par le client.
enum BookingPaymentModeKind {
  /// 20 % dans l’app, solde sur place.
  deposit20,

  /// 100 % de la prestation chez le prestataire.
  onSite,
}

extension BookingPaymentModeKindX on BookingPaymentModeKind {
  String get wireValue => switch (this) {
        BookingPaymentModeKind.deposit20 => 'deposit_20',
        BookingPaymentModeKind.onSite => 'on_site',
      };

  static BookingPaymentModeKind? fromWire(String? raw) => switch (raw) {
        'deposit_20' => BookingPaymentModeKind.deposit20,
        'on_site' => BookingPaymentModeKind.onSite,
        _ => null,
      };
}

/// Montants calculés pour l’écran récap et le PaymentIntent.
class BookingPricingBreakdown {
  const BookingPricingBreakdown({
    required this.paymentMode,
    required this.servicePriceCents,
    required this.depositCents,
    required this.platformFeeCents,
    required this.prestatairePortionCents,
    required this.totalChargeCents,
    required this.balanceOnSiteCents,
    required this.requiresInAppPayment,
    required this.priorBookingCount,
    required this.platformFeeFreeBookingCount,
    this.originalServicePriceCents,
    this.referralDiscountPercent,
  });

  final BookingPaymentModeKind paymentMode;
  /// Prix prestation facturé (après remise parrainage éventuelle).
  final int servicePriceCents;
  final int depositCents;
  final int platformFeeCents;
  final int prestatairePortionCents;
  final int totalChargeCents;
  final int balanceOnSiteCents;
  final bool requiresInAppPayment;
  final int priorBookingCount;
  final int platformFeeFreeBookingCount;
  final int? originalServicePriceCents;
  final int? referralDiscountPercent;

  bool get hasReferralDiscount =>
      referralDiscountPercent != null &&
      referralDiscountPercent! > 0 &&
      originalServicePriceCents != null &&
      originalServicePriceCents! > servicePriceCents;

  int get referralDiscountCents =>
      hasReferralDiscount ? originalServicePriceCents! - servicePriceCents : 0;

  bool get isPlatformFeeOnly =>
      prestatairePortionCents == 0 && platformFeeCents > 0;

  double get servicePriceEur => servicePriceCents / 100;
  double get totalChargeEur => totalChargeCents / 100;
  double get balanceOnSiteEur => balanceOnSiteCents / 100;
}

int platformFeeCentsForPriorCount(
  int priorBookingCount,
  BookingPlatformFeeSettings settings,
) {
  if (priorBookingCount < settings.freeBookingCount) return 0;
  return settings.feeCents;
}

int depositCentsFromService(int servicePriceCents) {
  return ((servicePriceCents * PricingConfig.depositPercent) / 100).round();
}

int discountedServicePriceCents(int originalCents, int discountPercent) {
  return ((originalCents * (100 - discountPercent)) / 100).round();
}

/// [priorBookingCount] = nombre de réservations déjà enregistrées (hors annulées).
BookingPricingBreakdown computeBookingPricing({
  required double servicePriceEur,
  required BookingPaymentModeKind paymentMode,
  required int priorBookingCount,
  required bool prestataireAcceptsConnect,
  BookingPlatformFeeSettings platformFeeSettings =
      BookingPlatformFeeSettings.defaults,
  int? referralDiscountPercent,
}) {
  final originalServicePriceCents = (servicePriceEur * 100).round();
  final percent = referralDiscountPercent;
  final servicePriceCents = percent != null && percent > 0
      ? discountedServicePriceCents(originalServicePriceCents, percent)
      : originalServicePriceCents;
  final platformFee = platformFeeCentsForPriorCount(
    priorBookingCount,
    platformFeeSettings,
  );

  switch (paymentMode) {
    case BookingPaymentModeKind.deposit20:
      if (!prestataireAcceptsConnect) {
        throw const BookingPricingException(
          'deposit_requires_connect',
        );
      }
      final deposit = depositCentsFromService(servicePriceCents);
      final total = deposit + platformFee;
      return BookingPricingBreakdown(
        paymentMode: paymentMode,
        servicePriceCents: servicePriceCents,
        depositCents: deposit,
        platformFeeCents: platformFee,
        prestatairePortionCents: deposit,
        totalChargeCents: total,
        balanceOnSiteCents: servicePriceCents - deposit,
        requiresInAppPayment: total > 0,
        priorBookingCount: priorBookingCount,
        platformFeeFreeBookingCount: platformFeeSettings.freeBookingCount,
        originalServicePriceCents: percent != null && percent > 0
            ? originalServicePriceCents
            : null,
        referralDiscountPercent: percent != null && percent > 0 ? percent : null,
      );
    case BookingPaymentModeKind.onSite:
      return BookingPricingBreakdown(
        paymentMode: paymentMode,
        servicePriceCents: servicePriceCents,
        depositCents: 0,
        platformFeeCents: 0,
        prestatairePortionCents: 0,
        totalChargeCents: 0,
        balanceOnSiteCents: servicePriceCents,
        requiresInAppPayment: false,
        priorBookingCount: priorBookingCount,
        platformFeeFreeBookingCount: platformFeeSettings.freeBookingCount,
        originalServicePriceCents: percent != null && percent > 0
            ? originalServicePriceCents
            : null,
        referralDiscountPercent: percent != null && percent > 0 ? percent : null,
      );
  }
}

class BookingPricingException implements Exception {
  const BookingPricingException(this.code);
  final String code;

  @override
  String toString() => 'BookingPricingException($code)';
}

import 'dart:math' as math;

import 'package:madbeauty/core/config/loyalty_config.dart';
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
    this.vipDiscountPercent,
    this.loyaltyRewardCents,
  });

  final BookingPaymentModeKind paymentMode;

  /// Prix prestation facturé (après remises + fidélité éventuels).
  final int servicePriceCents;
  final int depositCents;
  final int platformFeeCents;
  final int prestatairePortionCents;
  final int totalChargeCents;
  final int balanceOnSiteCents;
  final bool requiresInAppPayment;
  final int priorBookingCount;
  final int platformFeeFreeBookingCount;

  /// Prix catalogue brut (avant remises), si une remise/fidélité s’applique.
  final int? originalServicePriceCents;
  final int? referralDiscountPercent;
  final int? vipDiscountPercent;

  /// Montant couvert par la récompense fidélité (centimes).
  final int? loyaltyRewardCents;

  bool get hasReferralDiscount =>
      referralDiscountPercent != null &&
      referralDiscountPercent! > 0 &&
      originalServicePriceCents != null;

  bool get hasVipDiscount =>
      vipDiscountPercent != null &&
      vipDiscountPercent! > 0 &&
      originalServicePriceCents != null;

  int get priceAfterReferralCents {
    final original = originalServicePriceCents;
    if (original == null) {
      return servicePriceCents + (loyaltyRewardCents ?? 0);
    }
    final percent = referralDiscountPercent;
    if (percent != null && percent > 0) {
      return discountedServicePriceCents(original, percent);
    }
    return original;
  }

  int get priceAfterVipCents {
    final afterReferral = priceAfterReferralCents;
    final vip = vipDiscountPercent;
    if (vip != null && vip > 0) {
      return discountedServicePriceCents(afterReferral, vip);
    }
    return afterReferral;
  }

  int get referralDiscountCents {
    if (!hasReferralDiscount) return 0;
    return originalServicePriceCents! - priceAfterReferralCents;
  }

  int get vipDiscountCents {
    if (!hasVipDiscount) return 0;
    return priceAfterReferralCents - priceAfterVipCents;
  }

  bool get hasLoyaltyReward =>
      loyaltyRewardCents != null && loyaltyRewardCents! > 0;

  bool get isPlatformFeeOnly =>
      prestatairePortionCents == 0 && platformFeeCents > 0;

  bool get isFullyCoveredByLoyalty =>
      hasLoyaltyReward && servicePriceCents <= 0;

  double get servicePriceEur => servicePriceCents / 100;
  double get totalChargeEur => totalChargeCents / 100;
  double get balanceOnSiteEur => balanceOnSiteCents / 100;
  double get loyaltyRewardEur => (loyaltyRewardCents ?? 0) / 100;
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

int loyaltyCoverCents(int priceAfterDiscountsCents, {int? maxCents}) {
  final max = maxCents ?? LoyaltyConfig.maxRewardCents;
  return math.min(priceAfterDiscountsCents, max);
}

/// [priorBookingCount] = nombre de réservations déjà enregistrées (hors annulées).
/// Ordre remises : catalogue → parrainage → VIP salon → fidélité.
BookingPricingBreakdown computeBookingPricing({
  required double servicePriceEur,
  required BookingPaymentModeKind paymentMode,
  required int priorBookingCount,
  required bool prestataireAcceptsConnect,
  BookingPlatformFeeSettings platformFeeSettings =
      BookingPlatformFeeSettings.defaults,
  int? referralDiscountPercent,
  int? vipDiscountPercent,
  bool applyLoyaltyReward = false,
}) {
  final originalServicePriceCents = (servicePriceEur * 100).round();
  final referralPercent = referralDiscountPercent;
  final afterReferral = referralPercent != null && referralPercent > 0
      ? discountedServicePriceCents(originalServicePriceCents, referralPercent)
      : originalServicePriceCents;

  final vipPercent = vipDiscountPercent;
  final afterVip = vipPercent != null && vipPercent > 0
      ? discountedServicePriceCents(afterReferral, vipPercent)
      : afterReferral;

  final loyaltyReward = applyLoyaltyReward
      ? loyaltyCoverCents(afterVip)
      : 0;
  final servicePriceCents = math.max(afterVip - loyaltyReward, 0);

  final needsOriginalSnapshot = (referralPercent != null && referralPercent > 0) ||
      (vipPercent != null && vipPercent > 0) ||
      loyaltyReward > 0;

  var platformFee = platformFeeCentsForPriorCount(
    priorBookingCount,
    platformFeeSettings,
  );
  // Récompense fidélité : pas de frais plateforme sur cette résa.
  if (loyaltyReward > 0) {
    platformFee = 0;
  }

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
        originalServicePriceCents:
            needsOriginalSnapshot ? originalServicePriceCents : null,
        referralDiscountPercent:
            referralPercent != null && referralPercent > 0 ? referralPercent : null,
        vipDiscountPercent:
            vipPercent != null && vipPercent > 0 ? vipPercent : null,
        loyaltyRewardCents: loyaltyReward > 0 ? loyaltyReward : null,
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
        originalServicePriceCents:
            needsOriginalSnapshot ? originalServicePriceCents : null,
        referralDiscountPercent:
            referralPercent != null && referralPercent > 0 ? referralPercent : null,
        vipDiscountPercent:
            vipPercent != null && vipPercent > 0 ? vipPercent : null,
        loyaltyRewardCents: loyaltyReward > 0 ? loyaltyReward : null,
      );
  }
}

class BookingPricingException implements Exception {
  const BookingPricingException(this.code);
  final String code;

  @override
  String toString() => 'BookingPricingException($code)';
}

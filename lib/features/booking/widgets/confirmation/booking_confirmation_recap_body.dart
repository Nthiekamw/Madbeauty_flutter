import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/utils/currency_format.dart';
import '../../logic/booking_formatters.dart';
import '../../logic/booking_pricing.dart';
import 'booking_checkout_panel.dart';
import 'booking_confirmation_recap.dart';
import '../shared/booking_message.dart';
import '../../../../shared/widgets/app/app_button.dart';

/// Corps scrollable de l'écran confirmation (hors chargement prestataire).
class BookingConfirmationRecapBody extends StatelessWidget {
  const BookingConfirmationRecapBody({
    super.key,
    required this.prestataireName,
    required this.avatarUrl,
    required this.ville,
    required this.serviceName,
    required this.dateTime,
    required this.durationMinutes,
    required this.price,
    required this.breakdown,
    required this.effectiveMode,
    required this.acceptsOnline,
    required this.stripeAvailable,
    required this.isOwnProfile,
    required this.isSubmitting,
    required this.acceptsOnlineLoading,
    required this.errorMessage,
    required this.ctaLabel,
    required this.onPaymentModeChanged,
    required this.onConfirm,
    this.loyaltyAvailable = false,
    this.applyLoyaltyReward = false,
    this.onApplyLoyaltyChanged,
    this.loyaltyMaxRewardEuros = 50,
  });

  final String prestataireName;
  final String? avatarUrl;
  final String? ville;
  final String serviceName;
  final DateTime dateTime;
  final int durationMinutes;
  final double price;
  final BookingPricingBreakdown? breakdown;
  final BookingPaymentModeKind effectiveMode;
  final bool acceptsOnline;
  final bool stripeAvailable;
  final bool isOwnProfile;
  final bool isSubmitting;
  final bool acceptsOnlineLoading;
  final String? errorMessage;
  final String ctaLabel;
  final ValueChanged<BookingPaymentModeKind> onPaymentModeChanged;
  final VoidCallback onConfirm;
  final bool loyaltyAvailable;
  final bool applyLoyaltyReward;
  final ValueChanged<bool>? onApplyLoyaltyChanged;
  final int loyaltyMaxRewardEuros;

  static String formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final layout = DiscoveryResponsive.of(context);
    final useWeb = layout.useWebSiteLayout;
    final hPad = useWeb ? 20.0 : 20.0;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24 + bottomInset),
      children: [
        BookingConfirmationHeroCard(
          prestataireName: prestataireName,
          avatarUrl: avatarUrl,
          ville: ville,
          theme: theme,
          primary: primary,
          isDark: isDark,
          prestataireLabel: DiscBk.recapPresta,
        ),
        const SizedBox(height: 20),
        Text(
          'Détails de la réservation',
          style: theme.textTheme.titleSmall?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        BookingConfirmationRecapCard(
          rows: [
            BookingConfirmationRecapRow(
              icon: Icons.content_cut_rounded,
              label: DiscBk.recapSvc,
              value: serviceName,
            ),
            BookingConfirmationRecapRow(
              icon: Icons.calendar_today_rounded,
              label: DiscBk.recapDate,
              value: formatBookingDate(dateTime),
            ),
            BookingConfirmationRecapRow(
              icon: Icons.schedule_rounded,
              label: DiscBk.recapTime,
              value: formatTime(dateTime),
            ),
          ],
        ),
        const SizedBox(height: 10),
        BookingConfirmationPriceHighlight(
          label: DiscBk.recapPrice,
          value: breakdown != null &&
                  (breakdown!.hasReferralDiscount ||
                      breakdown!.hasVipDiscount ||
                      breakdown!.hasLoyaltyReward)
              ? CurrencyFormat.eurCents(breakdown!.servicePriceCents)
              : CurrencyFormat.eur(price, decimals: true),
          originalValue: breakdown != null &&
                  (breakdown!.hasReferralDiscount ||
                      breakdown!.hasVipDiscount ||
                      breakdown!.hasLoyaltyReward)
              ? CurrencyFormat.eur(price, decimals: true)
              : null,
          meta: formatBookingServiceMeta(
            durationMinutes: durationMinutes,
            price: breakdown != null &&
                    (breakdown!.hasReferralDiscount ||
                        breakdown!.hasVipDiscount ||
                        breakdown!.hasLoyaltyReward)
                ? breakdown!.servicePriceEur
                : price,
          ),
          theme: theme,
          primary: primary,
          isDark: isDark,
        ),
        if (breakdown != null && breakdown!.hasReferralDiscount) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.local_offer_outlined,
                  size: 20,
                  color: Color(0xFF6D28D9),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    DiscPay.recapReferralDiscountBanner,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF5B21B6),
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (breakdown != null && breakdown!.hasVipDiscount) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF0F766E).withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.workspace_premium_outlined,
                  size: 20,
                  color: Color(0xFF0F766E),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    DiscPay.recapVipDiscountBanner,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF115E59),
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: isDark ? 0.35 : 0.65),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  DiscBk.recapCancelPolicy,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: AppFonts.body,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (breakdown != null) ...[
          BookingCheckoutPanel(
            breakdown: breakdown!,
            paymentMode: effectiveMode,
            prestataireAcceptsDeposit: acceptsOnline,
            stripeAvailable: stripeAvailable,
            onPaymentModeChanged: onPaymentModeChanged,
            loyaltyAvailable: loyaltyAvailable,
            applyLoyaltyReward: applyLoyaltyReward,
            onApplyLoyaltyChanged: onApplyLoyaltyChanged,
            loyaltyMaxRewardEuros: loyaltyMaxRewardEuros,
          ),
          const SizedBox(height: 14),
        ],
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (breakdown?.requiresInAppPayment == true
                    ? const Color(0xFF10B981)
                    : theme.colorScheme.primary)
                .withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (breakdown?.requiresInAppPayment == true
                      ? const Color(0xFF10B981)
                      : theme.colorScheme.primary)
                  .withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                breakdown?.requiresInAppPayment == true
                    ? Icons.shield_outlined
                    : Icons.payments_outlined,
                size: 18,
                color: breakdown?.requiresInAppPayment == true
                    ? const Color(0xFF10B981)
                    : theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  breakdown?.requiresInAppPayment == true
                      ? DiscPay.recapTrust
                      : stripeAvailable
                          ? DiscPay.recapTrustOnSite
                          : DiscBk.recapTrust,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: AppFonts.body,
                    color: breakdown?.requiresInAppPayment == true
                        ? const Color(0xFF10B981)
                        : theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!stripeAvailable && breakdown?.requiresInAppPayment == true) ...[
          const SizedBox(height: 12),
          const BookingMessage(
            icon: Icons.payment_outlined,
            title: 'Paiement indisponible',
            message: DiscPay.errNotConfigured,
          ),
        ],
        if (errorMessage != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_rounded,
                  color: theme.colorScheme.onErrorContainer,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (isOwnProfile) ...[
          const SizedBox(height: 12),
          const BookingMessage(
            icon: Icons.person_outline,
            title: DiscBk.cannotBookOwnTitle,
            message: DiscBk.cannotBookOwnBody,
          ),
        ],
        const SizedBox(height: 24),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: !isSubmitting && !isOwnProfile && !isDark
                ? [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: AppButton(
            isLoading: isSubmitting || acceptsOnlineLoading,
            enabled: !isSubmitting && !isOwnProfile && !acceptsOnlineLoading,
            onPressed: isSubmitting || isOwnProfile ? null : onConfirm,
            child: Text(ctaLabel),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

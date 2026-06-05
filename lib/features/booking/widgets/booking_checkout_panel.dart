import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../logic/booking_pricing.dart';

/// Choix du mode de paiement + détail des montants (récap réservation).
class BookingCheckoutPanel extends StatelessWidget {
  const BookingCheckoutPanel({
    super.key,
    required this.breakdown,
    required this.paymentMode,
    required this.onPaymentModeChanged,
    required this.prestataireAcceptsDeposit,
    required this.stripeAvailable,
  });

  final BookingPricingBreakdown breakdown;
  final BookingPaymentModeKind paymentMode;
  final ValueChanged<BookingPaymentModeKind> onPaymentModeChanged;
  final bool prestataireAcceptsDeposit;
  final bool stripeAvailable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DiscPay.paymentModeTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        if (stripeAvailable && prestataireAcceptsDeposit)
          _ModeTile(
            selected: paymentMode == BookingPaymentModeKind.deposit20,
            title: DiscPay.paymentModeDeposit20,
            subtitle: DiscPay.paymentModeDeposit20Hint.replaceFirst(
              '%s',
              _formatEur(breakdown.paymentMode == BookingPaymentModeKind.deposit20
                  ? breakdown.balanceOnSiteEur
                  : breakdown.servicePriceEur * 0.8),
            ),
            icon: Icons.account_balance_wallet_outlined,
            onTap: () => onPaymentModeChanged(BookingPaymentModeKind.deposit20),
          ),
        if (stripeAvailable && prestataireAcceptsDeposit) const SizedBox(height: 8),
        _ModeTile(
          selected: paymentMode == BookingPaymentModeKind.onSite,
          title: DiscPay.paymentModeOnSite,
          subtitle: DiscPay.paymentModeOnSiteHint,
          icon: Icons.storefront_outlined,
          onTap: () => onPaymentModeChanged(BookingPaymentModeKind.onSite),
        ),
        const SizedBox(height: 16),
        _AmountCard(theme: theme, primary: primary, breakdown: breakdown),
      ],
    );
  }

  static String _formatEur(double value) => '${value.toStringAsFixed(2)} €';
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: selected
          ? primary.withValues(alpha: 0.08)
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? primary.withValues(alpha: 0.45)
                  : theme.colorScheme.outline.withValues(alpha: 0.15),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? primary : theme.colorScheme.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: primary.withValues(alpha: 0.7), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.theme,
    required this.primary,
    required this.breakdown,
  });

  final ThemeData theme;
  final Color primary;
  final BookingPricingBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          if (breakdown.hasReferralDiscount) ...[
            _line(
              DiscPay.checkoutServiceAfterDiscount,
              breakdown.servicePriceCents,
              theme,
            ),
            _line(
              '${DiscPay.checkoutReferralDiscount} (−${breakdown.referralDiscountPercent} %)',
              -breakdown.referralDiscountCents,
              theme,
              muted: true,
            ),
          ],
          if (breakdown.depositCents > 0)
            _line(
              DiscPay.checkoutDeposit,
              breakdown.depositCents,
              theme,
            ),
          if (breakdown.platformFeeCents > 0)
            _line(
              DiscPay.checkoutPlatformFee,
              breakdown.platformFeeCents,
              theme,
            )
          else if (breakdown.priorBookingCount < 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                DiscPay.checkoutFreePlatform,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const Divider(height: 20),
          _line(
            DiscPay.checkoutDueNow,
            breakdown.totalChargeCents,
            theme,
            bold: true,
          ),
          if (breakdown.balanceOnSiteCents > 0) ...[
            const SizedBox(height: 8),
            _line(
              DiscPay.checkoutOnSiteLater,
              breakdown.balanceOnSiteCents,
              theme,
              muted: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _line(
    String label,
    int cents,
    ThemeData theme, {
    bool bold = false,
    bool muted = false,
  }) {
    final value = '${(cents / 100).toStringAsFixed(2)} €';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: (bold
                      ? theme.textTheme.titleSmall
                      : theme.textTheme.bodyMedium)
                  ?.copyWith(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                color: muted ? theme.colorScheme.onSurfaceVariant : null,
              ),
            ),
          ),
          Text(
            value,
            style: (bold
                    ? theme.textTheme.titleSmall
                    : theme.textTheme.bodyMedium)
                ?.copyWith(
              fontWeight: FontWeight.w700,
              color: muted
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

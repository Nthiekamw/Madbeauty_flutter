import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/utils/currency_format.dart';
import '../../logic/booking_pricing.dart';

/// Détail des montants (récap réservation, paiement sur place).
class BookingCheckoutPanel extends StatelessWidget {
  const BookingCheckoutPanel({
    super.key,
    required this.breakdown,
  });

  final BookingPricingBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DiscPay.recapAmountTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        _AmountCard(theme: theme, primary: primary, breakdown: breakdown),
      ],
    );
  }

  static String _formatEur(double value) =>
      CurrencyFormat.eur(value, decimals: true);
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          _AmountRow(
            label: DiscPay.checkoutServiceAfterDiscount,
            value: BookingCheckoutPanel._formatEur(breakdown.servicePriceEur),
          ),
          if (breakdown.platformFeeCents > 0) ...[
            const SizedBox(height: 8),
            _AmountRow(
              label: DiscPay.checkoutPlatformFee,
              value: CurrencyFormat.eurCents(breakdown.platformFeeCents),
            ),
          ],
          const Divider(height: 20),
          _AmountRow(
            label: DiscPay.checkoutDueOnSite,
            value: BookingCheckoutPanel._formatEur(breakdown.servicePriceEur),
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: emphasized
                ? theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  )
                : theme.textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: emphasized
              ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)
              : theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

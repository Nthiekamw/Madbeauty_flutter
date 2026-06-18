import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/config/stripe_test_mode.dart';
import '../../../core/constants/app_strings.dart';
import '../../../services/stripe/stripe_service.dart';
import '../../widgets/app/app_snack_bar.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';

/// Bandeau carte de test Stripe (abonnement prestataire, mode `pk_test_`).
class StripeTestCardHint extends StatelessWidget {
  const StripeTestCardHint({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!StripeService.isTestMode) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: AppColors.brandGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.science_outlined,
                color: AppColors.brandGoldDark,
                size: compact ? 18 : 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DiscPrestaSub.testModeBannerTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                        fontSize: compact ? 12 : 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DiscPrestaSub.testModeBannerBody,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: compact ? 10 : 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 8 : 10),
          Material(
            color: theme.colorScheme.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () => _copyCardNumber(context),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            StripeTestCard.numberDisplay,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontFamily: AppFonts.display,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              fontSize: compact ? 13 : 14,
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DiscPrestaSub.testCardExpiryLabel} '
                            '${StripeTestCard.expiry} · '
                            '${DiscPrestaSub.testCardCvcLabel} '
                            '${StripeTestCard.cvc}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: compact ? 10 : 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: DiscPrestaSub.testCardCopyTooltip,
                      child: Icon(
                        Icons.copy_rounded,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyCardNumber(BuildContext context) async {
    await Clipboard.setData(
      const ClipboardData(text: StripeTestCard.numberRaw),
    );
    if (!context.mounted) return;
    AppSnackBar.show(context, message: DiscPrestaSub.testCardCopied);
  }
}

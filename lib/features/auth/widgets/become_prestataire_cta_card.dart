import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/widgets/app/app_button.dart';

/// Carte d’incitation « Devenir prestataire » (profil client seul).
class BecomePrestataireCtaCard extends StatelessWidget {
  const BecomePrestataireCtaCard({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: DiscoveryStyles.heroBorderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: isDark ? 0.35 : 0.12),
            theme.colorScheme.secondary.withValues(alpha: isDark ? 0.2 : 0.08),
          ],
        ),
        border: Border.all(color: primary.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DiscProfile.becomePrestaCardTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DiscProfile.becomePrestaCardBody,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const _BenefitRow(text: DiscProfile.becomePrestaBenefit1),
            const SizedBox(height: 6),
            const _BenefitRow(text: DiscProfile.becomePrestaBenefit2),
            const SizedBox(height: 6),
            const _BenefitRow(text: DiscProfile.becomePrestaBenefit3),
            const SizedBox(height: 16),
            AppButton(
              onPressed: onTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DiscProfile.becomePrestaCta),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: theme.colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Row(
      children: [
        Icon(Icons.check_circle_rounded, size: 16, color: primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

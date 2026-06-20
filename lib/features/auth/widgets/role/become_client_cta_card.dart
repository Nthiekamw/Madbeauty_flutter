import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/discovery_styles.dart';
import '../../../../shared/widgets/app/app_button.dart';

/// Carte d’incitation « Activer l’espace client » (profil prestataire seul).
class BecomeClientCtaCard extends StatelessWidget {
  const BecomeClientCtaCard({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final compact = MediaQuery.sizeOf(context).width < 390;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: DiscoveryStyles.heroBorderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: isDark ? 0.28 : 0.1),
            theme.colorScheme.tertiary.withValues(alpha: isDark ? 0.18 : 0.06),
          ],
        ),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? 14 : 18,
          compact ? 14 : 18,
          compact ? 14 : 18,
          compact ? 14 : 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: compact ? 42 : 52,
                  height: compact ? 42 : 52,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(
                    Icons.spa_rounded,
                    color: primary,
                    size: compact ? 22 : 28,
                  ),
                ),
                SizedBox(width: compact ? 10 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DiscProfile.becomeClientCardTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          fontSize: compact ? 15 : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: compact ? 4 : 6),
                      Text(
                        DiscProfile.becomeClientCardBody,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                          fontSize: compact ? 11.5 : null,
                        ),
                        maxLines: compact ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 10 : 14),
            const _BenefitRow(text: DiscProfile.becomeClientBenefit1),
            SizedBox(height: compact ? 4 : 6),
            const _BenefitRow(text: DiscProfile.becomeClientBenefit2),
            SizedBox(height: compact ? 12 : 16),
            AppButton(
              onPressed: onTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      DiscProfile.becomeClientCta,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: compact ? 16 : 18,
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
    final compact = MediaQuery.sizeOf(context).width < 390;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_rounded, size: compact ? 14 : 16, color: primary),
        SizedBox(width: compact ? 6 : 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 11.5 : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

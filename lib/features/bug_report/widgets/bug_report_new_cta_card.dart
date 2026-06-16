import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';

/// Carte d’action principale pour créer un nouveau signalement de bug.
class BugReportNewCtaCard extends StatelessWidget {
  const BugReportNewCtaCard({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: AppColors.transparent,
      borderRadius: DiscoveryStyles.cardBorderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.brandBrownMid.withValues(alpha: 0.95),
                      AppColors.brandBrown.withValues(alpha: 0.88),
                    ]
                  : [
                      AppColors.brandBrown,
                      AppColors.brandBrownMid,
                    ],
            ),
            borderRadius: DiscoveryStyles.cardBorderRadius,
            boxShadow: [
              BoxShadow(
                color: AppColors.brandBrown.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.add_rounded,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DiscBug.actionNewReport,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: AppFonts.display,
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DiscBug.actionNewReportHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: AppFonts.body,
                          color: AppColors.white.withValues(alpha: 0.92),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.white.withValues(alpha: 0.92),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

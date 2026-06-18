import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/theme/discovery_styles.dart';

/// Barre d'action fixe en bas de l'écran.
class PrestataireDetailBottomBar extends StatelessWidget {
  const PrestataireDetailBottomBar({
    super.key,
    required this.minPrice,
    required this.onBook,
  });

  final double? minPrice;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final layout = DiscoveryResponsive.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceFor(theme.brightness),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(
              alpha: isDark ? 0.2 : 0.1,
            ),
          ),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.brandBrown.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          layout.horizontalPadding,
          10,
          layout.horizontalPadding,
          10 + bottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: layout.contentMaxWidth),
            child: Row(
              children: [
                if (minPrice != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DiscPrestaDetail.fromPrice,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '${minPrice!.toStringAsFixed(0)} €',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onBook,
                    icon: const Icon(Icons.calendar_month_rounded, size: 17),
                    label: Text(
                      DiscPrestaDetail.actionBook,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      minimumSize: const Size(0, 44),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: DiscoveryStyles.chipBorderRadius,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

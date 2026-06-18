import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/models/domain/catalog/service_beaute.dart';
import '../../../../../../shared/theme/app_colors.dart';
import '../../../../../../shared/theme/app_fonts.dart';
import '../../../../../../shared/theme/discovery_styles.dart';

class PrestataireDetailServiceCard extends StatelessWidget {
  const PrestataireDetailServiceCard({
    super.key,
    required this.service,
    required this.onBook,
    required this.canBook,
  });

  final ServiceBeaute service;
  final VoidCallback onBook;
  final bool canBook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.cardSurfaceFor(theme.brightness),
        elevation: isDark ? 0 : 1,
        shadowColor: AppColors.brandBrown.withValues(alpha: 0.06),
        borderRadius: DiscoveryStyles.chipBorderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: canBook ? onBook : null,
          borderRadius: DiscoveryStyles.chipBorderRadius,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: DiscoveryStyles.chipBorderRadius,
              border: Border.all(
                color: theme.colorScheme.outline.withValues(
                  alpha: isDark ? 0.2 : 0.08,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.spa_outlined, size: 18, color: primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.nom,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontFamily: AppFonts.display,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${service.dureeMinutes} min',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${service.prix.toStringAsFixed(0)} €',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: primary,
                        ),
                      ),
                      if (canBook) ...[
                        const SizedBox(height: 2),
                        Text(
                          DiscPrestaDetail.actionBookSvc,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

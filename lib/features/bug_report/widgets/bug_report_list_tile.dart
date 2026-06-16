import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/bug_report.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import 'bug_report_status_chip.dart';

class BugReportListTile extends StatelessWidget {
  const BugReportListTile({
    super.key,
    required this.item,
    required this.dateFormat,
    required this.onTap,
  });

  final BugReport item;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  IconData _categoryIcon(String category) => switch (category) {
        'auth' => Icons.lock_outline_rounded,
        'booking' => Icons.event_outlined,
        'payment' => Icons.payment_outlined,
        'messaging' => Icons.chat_bubble_outline_rounded,
        'profile' => Icons.person_outline_rounded,
        _ => Icons.bug_report_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final note = item.reporterMessage?.trim();
    final isActive = item.status == 'pending' || item.status == 'in_progress';

    return DiscoverySurfaceCard(
      includeHorizontalMargin: false,
      padding: EdgeInsets.zero,
      child: Material(
        color: AppColors.transparent,
        borderRadius: DiscoveryStyles.cardBorderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.brandBrown.withValues(alpha: isDark ? 0.22 : 0.14)
                        : theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      _categoryIcon(item.category),
                      color: isActive
                          ? AppColors.brandBrownMid
                          : theme.colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontFamily: AppFonts.display,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          BugReportStatusChip(status: item.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${DiscBug.categoryLabel(item.category)} · '
                        '${dateFormat.format(item.createdAt.toLocal())}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: AppFonts.body,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (item.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.description.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: AppFonts.body,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.88,
                            ),
                            height: 1.35,
                          ),
                        ),
                      ],
                      if (note != null && note.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.mark_chat_read_outlined,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                note,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontFamily: AppFonts.body,
                                  color: theme.colorScheme.primary,
                                  fontStyle: FontStyle.italic,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            DiscBug.tileOpenDiscussion,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontFamily: AppFonts.body,
                              color: AppColors.brandBrownMid,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: AppColors.brandBrownMid,
                          ),
                        ],
                      ),
                    ],
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

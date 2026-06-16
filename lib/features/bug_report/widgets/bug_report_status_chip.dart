import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';

enum BugReportStatusTone { pending, progress, success, neutral }

BugReportStatusTone bugReportStatusTone(String status) => switch (status) {
      'pending' => BugReportStatusTone.pending,
      'in_progress' => BugReportStatusTone.progress,
      'resolved' => BugReportStatusTone.success,
      'closed' => BugReportStatusTone.neutral,
      _ => BugReportStatusTone.neutral,
    };

class BugReportStatusChip extends StatelessWidget {
  const BugReportStatusChip({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = bugReportStatusTone(status);
    final (bg, fg) = switch (tone) {
      BugReportStatusTone.pending => (
          AppColors.brandGoldGlow12,
          AppColors.brandGoldDark,
        ),
      BugReportStatusTone.progress => (
          AppColors.brandBrown.withValues(alpha: 0.16),
          AppColors.brandBrownMid,
        ),
      BugReportStatusTone.success => (
          theme.colorScheme.tertiaryContainer.withValues(alpha: 0.85),
          theme.colorScheme.onTertiaryContainer,
        ),
      BugReportStatusTone.neutral => (
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.onSurfaceVariant,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.22)),
      ),
      child: Text(
        DiscBug.statusLabel(status),
        style: theme.textTheme.labelSmall?.copyWith(
          fontFamily: AppFonts.body,
          color: fg,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

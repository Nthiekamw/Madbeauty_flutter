import 'package:flutter/material.dart';

import '../../../../shared/theme/app_fonts.dart';

/// En-tête de section avec icône (dashboard, profil, agenda).
class PrestataireSectionHeader extends StatelessWidget {
  const PrestataireSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.badgeCount,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final int? badgeCount;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = iconColor ?? theme.colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: AppFonts.body,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (badgeCount != null && badgeCount! > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$badgeCount',
              style: theme.textTheme.labelLarge?.copyWith(
                fontFamily: AppFonts.body,
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

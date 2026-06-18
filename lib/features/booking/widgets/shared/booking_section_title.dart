import 'package:flutter/material.dart';

import '../../../../shared/theme/app_fonts.dart';

/// Titre de section réservation (aligné sur l'accueil client).
class BookingSectionTitle extends StatelessWidget {
  const BookingSectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.compact = true,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final iconSize = compact ? 32.0 : 36.0;
    final glyphSize = compact ? 17.0 : 19.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(compact ? 10 : 12),
            ),
            child: Icon(icon, color: accent, size: glyphSize),
          ),
          SizedBox(width: compact ? 8 : 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 13 : 14,
                  letterSpacing: -0.2,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: AppFonts.body,
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

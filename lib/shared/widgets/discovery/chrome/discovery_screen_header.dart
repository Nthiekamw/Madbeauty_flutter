import 'package:flutter/material.dart';

import '../../../theme/app_fonts.dart';

/// En-tête des écrans client (recherche, réservations, profil).
class DiscoveryScreenHeader extends StatelessWidget {
  const DiscoveryScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.action,
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final bool compact;
  final IconData? icon;
  final Color? iconColor;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final effectiveIconColor = iconColor ?? primary;
    final screenW = MediaQuery.sizeOf(context).width;
    final isCompact = screenW < 360;
    final iconBoxSize = isCompact ? 40.0 : 48.0;
    final iconSize = isCompact ? 20.0 : 24.0;

    final dense = compact || isCompact;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        dense ? 16 : 20,
        dense ? 10 : 16,
        dense ? 16 : 20,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: iconBoxSize,
              height: iconBoxSize,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: effectiveIconColor.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(icon, color: effectiveIconColor, size: iconSize),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) const SizedBox(height: 2),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    height: 1.1,
                    fontSize: isCompact ? 20 : null,
                  ),
                ),
                if (subtitle != null && !compact) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: AppFonts.body,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 8),
            action!,
          ],
        ],
      ),
    );
  }
}


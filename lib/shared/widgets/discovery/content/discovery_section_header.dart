import 'package:flutter/material.dart';

import '../../../theme/app_fonts.dart';

/// En-tête de section aligné sur l'accueil client (icône + titre + action).
class DiscoverySectionHeader extends StatelessWidget {
  const DiscoverySectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    this.showSubtitleWhenCompact = false,
    this.icon,
    this.iconColor,
    this.badgeCount,
    this.padding = EdgeInsets.zero,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;
  final bool showSubtitleWhenCompact;
  final IconData? icon;
  final Color? iconColor;
  final int? badgeCount;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = iconColor ?? theme.colorScheme.primary;
    final showSubtitle = subtitle != null &&
        subtitle!.isNotEmpty &&
        (!compact || showSubtitleWhenCompact);

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 18 : 20, color: accent),
            SizedBox(width: compact ? 8 : 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: compact ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 13 : 15,
                    letterSpacing: 0,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (showSubtitle) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: AppFonts.body,
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (badgeCount != null && badgeCount! > 0)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$badgeCount',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: AppFonts.body,
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: theme.colorScheme.primary,
                ),
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

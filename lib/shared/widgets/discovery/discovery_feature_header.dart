import 'package:flutter/material.dart';

import '../../layout/discovery_responsive.dart';
import '../../theme/app_fonts.dart';

/// En-tête d'écran (réservations, messages…) – style carte dégradée.
class DiscoveryFeatureHeader extends StatelessWidget {
  const DiscoveryFeatureHeader({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.trailing,
    this.iconColor,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final effectiveIcon = iconColor ?? primary;
    final hPad = DiscoveryResponsive.of(context).horizontalPadding;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primary.withValues(alpha: isDark ? 0.4 : 0.68),
              theme.colorScheme.primaryContainer.withValues(
                alpha: isDark ? 0.52 : 0.85,
              ),
            ],
          ),
          border: Border.all(
            color: primary.withValues(alpha: isDark ? 0.22 : 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(
                    alpha: isDark ? 0.2 : 0.88,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: effectiveIcon.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: effectiveIcon,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.35,
                        height: 1.1,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: AppFonts.body,
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.82),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}


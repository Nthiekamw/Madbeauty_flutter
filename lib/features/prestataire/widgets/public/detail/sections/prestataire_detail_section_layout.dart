import 'package:flutter/material.dart';

import '../../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../../shared/theme/app_fonts.dart';
import 'prestataire_detail_surface.dart';

/// En-tête de section compact (aligné accueil client).
class PrestataireDetailSectionHeader extends StatelessWidget {
  const PrestataireDetailSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.compact = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
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
              if (!compact && subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: AppFonts.body,
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Bloc section avec carte surface (style accueil).
class PrestataireDetailSectionCard extends StatelessWidget {
  const PrestataireDetailSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = DiscoveryResponsive.of(context).horizontalPadding;

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 18, pad, 0),
      child: PrestataireDetailSurface.cardMaterial(
        theme: theme,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrestataireDetailSectionHeader(
              icon: icon,
              title: title,
              subtitle: subtitle,
              trailing: trailing,
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

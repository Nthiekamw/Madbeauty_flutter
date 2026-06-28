import 'package:flutter/material.dart';

import '../../../layout/discovery_responsive.dart';
import '../../../theme/app_fonts.dart';
import '../../../../shared/theme/app_colors.dart';

/// Ligne d'action dans une carte profil / menu client.
class DiscoveryMenuTile extends StatefulWidget {
  const DiscoveryMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.showChevron = true,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool showChevron;
  final bool destructive;

  @override
  State<DiscoveryMenuTile> createState() => _DiscoveryMenuTileState();
}

class _DiscoveryMenuTileState extends State<DiscoveryMenuTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layout = DiscoveryResponsive.of(context);
    final useWeb = layout.useWebSiteLayout;
    final color = widget.destructive
        ? theme.colorScheme.error
        : (widget.iconColor ?? theme.colorScheme.primary);
    final enabled = widget.onTap != null;
    final iconBox = useWeb ? 46.0 : 44.0;

    final tile = Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        hoverColor: useWeb
            ? theme.colorScheme.primary.withValues(alpha: 0.05)
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          color: useWeb && _hovered && enabled
              ? theme.colorScheme.primary.withValues(alpha: 0.04)
              : AppColors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: useWeb ? 18 : 16,
            vertical: useWeb ? 14 : 12,
          ),
          child: Row(
            children: [
              Container(
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: useWeb ? 0.12 : 0.1),
                  borderRadius: BorderRadius.circular(useWeb ? 14 : 12),
                  border: useWeb
                      ? Border.all(color: color.withValues(alpha: 0.16))
                      : null,
                ),
                child: Icon(widget.icon, color: color, size: useWeb ? 23 : 22),
              ),
              SizedBox(width: useWeb ? 16 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w700,
                        fontSize: useWeb ? 15 : null,
                        color: widget.destructive
                            ? theme.colorScheme.error
                            : null,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: AppFonts.body,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  size: useWeb ? 24 : 22,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: enabled ? 0.55 : 0.35,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (!useWeb || !enabled) return tile;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: tile,
    );
  }
}

import 'package:flutter/material.dart';

import '../../theme/app_fonts.dart';
import '../../theme/discovery_styles.dart';

/// État vide ou message centré (recherche, réservations, invité).
class DiscoveryEmptyState extends StatelessWidget {
  const DiscoveryEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    this.extraActions,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color? iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final List<Widget>? extraActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.85 : 0.95,
            ),
            borderRadius: DiscoveryStyles.cardBorderRadius,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 52,
                  color: iconColor ?? theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: AppFonts.body,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
                ],
                if (extraActions != null) ...[
                  const SizedBox(height: 12),
                  ...extraActions!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../theme/app_fonts.dart';
import '../../../theme/discovery_styles.dart';

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
    this.compact,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color? iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final List<Widget>? extraActions;

  /// Variante compacte ; par défaut dérivée de la hauteur d'écran.
  final bool? compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact =
        compact ?? MediaQuery.sizeOf(context).height < 640;
    final outerPadding = isCompact ? 12.0 : 28.0;
    final cardPadding = isCompact
        ? const EdgeInsets.fromLTRB(16, 16, 16, 14)
        : const EdgeInsets.fromLTRB(24, 28, 24, 24);
    final iconSize = isCompact ? 40.0 : 52.0;

    final card = DecoratedBox(
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
        padding: cardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: isCompact ? 10 : 16),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: isCompact ? 3 : null,
              overflow: isCompact ? TextOverflow.ellipsis : null,
              style: (isCompact
                      ? theme.textTheme.titleSmall
                      : theme.textTheme.titleMedium)
                  ?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: isCompact ? 6 : 8),
            Text(
              body,
              textAlign: TextAlign.center,
              maxLines: isCompact ? 4 : null,
              overflow: isCompact ? TextOverflow.ellipsis : null,
              style: (isCompact
                      ? theme.textTheme.bodySmall
                      : theme.textTheme.bodyMedium)
                  ?.copyWith(
                fontFamily: AppFonts.body,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: isCompact ? 14 : 20),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
            if (extraActions != null) ...[
              SizedBox(height: isCompact ? 8 : 12),
              ...extraActions!,
            ],
          ],
        ),
      ),
    );

    // Pas de LayoutBuilder : incompatible avec SliverFillRemaining (intrinsics).
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(outerPadding),
        child: card,
      ),
    );
  }
}


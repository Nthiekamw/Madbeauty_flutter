import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_colors.dart';
import 'client_workspace_header.dart';

/// Coque client : bandeau marron + panneau crème sous l'en-tête.
class ClientWorkspaceShell extends StatelessWidget {
  const ClientWorkspaceShell({
    super.key,
    required this.child,
    this.subtitle = DiscClientWorkspace.searchSubtitle,
    this.header,
    this.top,
    this.panelOverlap = -12,
  });

  final Widget child;
  final String subtitle;
  final Widget? header;
  final Widget? top;

  /// Décalage vertical du panneau crème sous l'en-tête marron.
  final double panelOverlap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header ?? ClientWorkspaceHeader(subtitle: subtitle),
        Expanded(
          child: Transform.translate(
            offset: Offset(0, panelOverlap),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.workspacePanelFor(theme.brightness),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(
                    alpha: isDark ? 0.22 : 0.08,
                  ),
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (top != null) top!,
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


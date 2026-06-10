import 'package:flutter/material.dart';

import '../../../../../shared/theme/app_colors.dart';
import 'prestataire_workspace_header.dart';

/// Corps d'écran prestataire : en-tête marron + panneau crème arrondi.
class PrestataireWorkspaceShell extends StatelessWidget {
  const PrestataireWorkspaceShell({
    super.key,
    required this.child,
    this.onRefresh,
    this.headerSubtitle,
    this.showMessagesAction = true,
  });

  final Widget child;
  final Future<void> Function()? onRefresh;
  final String? headerSubtitle;
  final bool showMessagesAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrestataireWorkspaceHeader(
          onRefresh: onRefresh,
          subtitle: headerSubtitle,
          showMessagesAction: showMessagesAction,
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.workspacePanelFor(theme.brightness),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: isDark
                    ? Border.all(
                        color: theme.colorScheme.outline.withValues(
                          alpha: 0.2,
                        ),
                      )
                    : null,
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(
                            alpha: 0.06,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, -2),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


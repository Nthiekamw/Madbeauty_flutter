import 'package:flutter/material.dart';

import 'prestataire_workspace_header.dart';

/// Corps d’écran prestataire : en-tête marron + zone blanche arrondie.
class PrestataireWorkspaceShell extends StatelessWidget {
  const PrestataireWorkspaceShell({
    super.key,
    required this.child,
    this.onRefresh,
  });

  final Widget child;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrestataireWorkspaceHeader(onRefresh: onRefresh),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.06),
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

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import 'client_workspace_header.dart';

/// Zone de contenu sous l’en-tête client (fond surface, coins arrondis).
class ClientWorkspaceShell extends StatelessWidget {
  const ClientWorkspaceShell({
    super.key,
    required this.child,
    this.subtitle = DiscClientWorkspace.searchSubtitle,
    this.header,
    this.top,
  });

  final Widget child;
  final String subtitle;
  final Widget? header;
  final Widget? top;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header ?? ClientWorkspaceHeader(subtitle: subtitle),
        if (top != null) top!,
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

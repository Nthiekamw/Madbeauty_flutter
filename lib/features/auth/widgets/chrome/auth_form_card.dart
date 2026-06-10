import 'package:flutter/material.dart';

import '../../../../shared/theme/auth_form_styles.dart';

/// Carte formulaire sur fond brand (connexion / inscription).
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({super.key, required this.child, this.compact = false});

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: isDark ? 0.92 : 0.97,
        ),
        borderRadius: AuthFormStyles.cardBorderRadius,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Padding(
        padding: compact
            ? const EdgeInsets.fromLTRB(14, 14, 14, 14)
            : const EdgeInsets.fromLTRB(20, 22, 20, 22),
        child: child,
      ),
    );
  }
}


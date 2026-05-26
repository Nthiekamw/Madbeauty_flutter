import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';

/// Séparateur « ou » entre formulaire et OAuth.
class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({
    super.key,
    this.label = AuthStrings.registerOrDivider,
    this.compact = false,
  });

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 10 : 20),
      child: Row(
        children: [
          Expanded(child: Divider(color: color.withValues(alpha: 0.35))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontFamily: AppFonts.body,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Divider(color: color.withValues(alpha: 0.35))),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../shared/theme/app_fonts.dart';

/// Groupe visuel titre + champs (connexion, inscription, etc.).
class AuthStepSection extends StatelessWidget {
  const AuthStepSection({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.subtitle,
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: compact ? 18 : 20,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: compact ? 6 : 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: (compact
                            ? theme.textTheme.labelLarge
                            : theme.textTheme.titleSmall)
                        ?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (subtitle != null && !compact) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
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
          ],
        ),
        SizedBox(height: compact ? 8 : 14),
        child,
      ],
    );
  }
}

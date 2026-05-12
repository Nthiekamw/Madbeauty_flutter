import 'package:flutter/material.dart';

import '../../../shared/widgets/app_avatar.dart';

/// En-tête accueil client : salutation + nom + avatar.
class ClientHomeHeader extends StatelessWidget {
  const ClientHomeHeader({
    super.key,
    required this.greetingLine,
    required this.subtitle,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.menuButton,
  });

  final String greetingLine;
  final String subtitle;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final Widget? menuButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greetingLine,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AppAvatar(
          imageUrl: avatarUrl,
          radius: 26,
          displayName: displayName.isEmpty ? null : displayName,
          email: email.isEmpty ? null : email,
        ),
        if (menuButton != null) ...[
          const SizedBox(width: 4),
          menuButton!,
        ],
      ],
    );
  }
}

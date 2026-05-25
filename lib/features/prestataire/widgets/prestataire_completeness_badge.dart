import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

/// Badge « profil complet / à compléter » (dashboard et profil prestataire).
class PrestataireCompletenessBadge extends StatelessWidget {
  const PrestataireCompletenessBadge({super.key, required this.complete});

  final bool complete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: complete
            ? theme.colorScheme.primary.withValues(alpha: 0.14)
            : theme.colorScheme.errorContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            complete ? Icons.check_circle_outline : Icons.info_outline,
            size: 16,
            color: complete
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
          const SizedBox(width: 6),
          Text(
            complete
                ? DiscPrestaDash.badgeComplete
                : DiscPrestaDash.badgeIncomplete,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: complete
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}

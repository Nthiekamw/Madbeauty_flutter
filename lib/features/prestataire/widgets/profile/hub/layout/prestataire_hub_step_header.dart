import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../shared/theme/app_fonts.dart';
import 'prestataire_hub_layout_core.dart';

/// En-tête d'étape : numéro, titre, objectif, badge.
class PrestataireHubStepHeader extends StatelessWidget {
  const PrestataireHubStepHeader({
    super.key,
    required this.stepIndex,
    required this.stepTotal,
    required this.icon,
    required this.title,
    required this.goal,
    this.requirement,
  });

  final int stepIndex;
  final int stepTotal;
  final IconData icon;
  final String title;
  final String goal;
  final HubStepRequirement? requirement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return PrestataireHubSurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary.withValues(alpha: 0.18),
                  primary.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: primary.withValues(alpha: 0.22)),
            ),
            child: Icon(icon, size: 26, color: primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          height: 1.15,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (requirement != null) ...[
                      const SizedBox(width: 8),
                      _HubRequirementChip(requirement: requirement!),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  goal,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HubRequirementChip extends StatelessWidget {
  const _HubRequirementChip({required this.requirement});

  final HubStepRequirement requirement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, bg, fg) = switch (requirement) {
      HubStepRequirement.required => (
        DiscPrestaForm.hubBadgeRequired,
        theme.colorScheme.primary.withValues(alpha: 0.14),
        theme.colorScheme.primary,
      ),
      HubStepRequirement.recommended => (
        DiscPrestaForm.hubBadgeRecommended,
        theme.colorScheme.secondaryContainer.withValues(alpha: 0.7),
        theme.colorScheme.onSecondaryContainer,
      ),
      HubStepRequirement.optional => (
        DiscPrestaForm.hubBadgeOptional,
        theme.colorScheme.surfaceContainerHighest,
        theme.colorScheme.onSurfaceVariant,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

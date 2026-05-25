import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/discovery_surface_card.dart';
import '../models/client_comfort_option.dart';
import '../models/service_condition_option.dart';
import 'prestataire_section_header.dart';

/// Affichage lecture seule : confort client + conditions de service.
class PrestataireClientExperienceSection extends StatelessWidget {
  const PrestataireClientExperienceSection({
    super.key,
    required this.comfortIds,
    required this.conditionIds,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final List<String> comfortIds;
  final List<String> conditionIds;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comforts = ClientComfortOption.resolve(comfortIds);
    final conditions = ServiceConditionOption.resolve(conditionIds);

    if (comforts.isEmpty && conditions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (comforts.isNotEmpty) ...[
            DiscoverySurfaceCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrestataireSectionHeader(
                    icon: Icons.favorite_outline_rounded,
                    title: DiscPrestaComfort.sectionComfortTitle,
                    subtitle: DiscPrestaComfort.sectionComfortHint,
                    iconColor: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option in comforts)
                        _ExperienceChip(
                          icon: option.icon,
                          label: option.label,
                          accent: theme.colorScheme.tertiary,
                          container: theme.colorScheme.tertiaryContainer,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (conditions.isNotEmpty)
            DiscoverySurfaceCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrestataireSectionHeader(
                    icon: Icons.rule_rounded,
                    title: DiscPrestaComfort.sectionConditionsTitle,
                    subtitle: DiscPrestaComfort.sectionConditionsHint,
                    iconColor: theme.colorScheme.secondary,
                  ),
                  const SizedBox(height: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < conditions.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        _ConditionRow(option: conditions[i]),
                      ],
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ExperienceChip extends StatelessWidget {
  const _ExperienceChip({
    required this.icon,
    required this.label,
    required this.accent,
    required this.container,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final Color container;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: container.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConditionRow extends StatelessWidget {
  const _ConditionRow({required this.option});

  final ServiceConditionOption option;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(option.icon, size: 20, color: theme.colorScheme.secondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            option.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: AppFonts.body,
              height: 1.4,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

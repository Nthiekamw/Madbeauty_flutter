import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../../shared/theme/app_fonts.dart';
import '../../../../models/client_comfort_option.dart';
import '../../../../models/experience_item_codec.dart';
import '../../../../models/service_condition_option.dart';

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
    final comforts = ClientComfortOption.resolve(comfortIds);
    final conditions = ServiceConditionOption.resolve(conditionIds);

    if (comforts.isEmpty && conditions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (comforts.isNotEmpty && conditions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SectionHeading(
                icon: Icons.spa_outlined,
                title: DiscPrestaComfort.menuTitle,
              ),
            ),
          if (comforts.isNotEmpty) ...[
            _ComfortBlock(comforts: comforts),
            if (conditions.isNotEmpty) const SizedBox(height: 14),
          ],
          if (conditions.isNotEmpty) _ConditionsBlock(conditions: conditions),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary.withValues(alpha: 0.85),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// â”€â”€â”€ Confort â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ComfortBlock extends StatelessWidget {
  const _ComfortBlock({required this.comforts});
  final List<ClientComfortOption> comforts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tertiary = theme.colorScheme.tertiary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  tertiary.withValues(alpha: 0.10),
                  tertiary.withValues(alpha: 0.04),
                ]
              : [
                  tertiary.withValues(alpha: 0.07),
                  theme.colorScheme.tertiaryContainer.withValues(alpha: 0.18),
                ],
        ),
        border: Border.all(
          color: tertiary.withValues(alpha: isDark ? 0.18 : 0.14),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: tertiary.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: _ExperienceBlockHeader(
              icon: Icons.favorite_rounded,
              accent: tertiary,
              isDark: isDark,
              title: DiscPrestaComfort.sectionComfortTitle,
              countLabel:
                  '${comforts.length} équipement${comforts.length > 1 ? 's' : ''}',
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in comforts)
                  _ComfortChip(
                    option: option,
                    accent: tertiary,
                    isDark: isDark,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComfortChip extends StatelessWidget {
  const _ComfortChip({
    required this.option,
    required this.accent,
    required this.isDark,
  });

  final ClientComfortOption option;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCustom = ExperienceItemCodec.isCustom(option.id);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? accent.withValues(alpha: 0.12)
            : theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.25 : 0.18),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: accent.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(option.icon, size: 14, color: accent),
          ),
          const SizedBox(width: 8),
          Text(
            option.label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (isCustom) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.star_rounded,
              size: 14,
              color: accent.withValues(alpha: 0.7),
            ),
          ],
        ],
      ),
    );
  }
}

// â”€â”€â”€ Conditions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ConditionsBlock extends StatelessWidget {
  const _ConditionsBlock({required this.conditions});
  final List<ServiceConditionOption> conditions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondary = theme.colorScheme.secondary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surface.withValues(alpha: isDark ? 0.6 : 0.95),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: isDark ? 0.14 : 0.09,
          ),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: secondary.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: _ExperienceBlockHeader(
              icon: Icons.rule_rounded,
              accent: secondary,
              isDark: isDark,
              title: DiscPrestaComfort.sectionConditionsTitle,
              countLabel:
                  '${conditions.length} règle${conditions.length > 1 ? 's' : ''}',
            ),
          ),
          Divider(
            height: 1,
            indent: 18,
            endIndent: 18,
            color: theme.colorScheme.outline.withValues(
              alpha: isDark ? 0.1 : 0.07,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
            child: Column(
              children: [
                for (var i = 0; i < conditions.length; i++) ...[
                  _ConditionTile(
                    option: conditions[i],
                    accent: secondary,
                    isDark: isDark,
                  ),
                  if (i < conditions.length - 1)
                    Divider(
                      height: 1,
                      color: theme.colorScheme.outline.withValues(
                        alpha: isDark ? 0.07 : 0.05,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceBlockHeader extends StatelessWidget {
  const _ExperienceBlockHeader({
    required this.icon,
    required this.accent,
    required this.isDark,
    required this.title,
    required this.countLabel,
  });

  final IconData icon;
  final Color accent;
  final bool isDark;
  final String title;
  final String countLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: isDark ? 0.18 : 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.1,
                ),
              ),
              Text(
                countLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: AppFonts.body,
                  color: accent.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConditionTile extends StatelessWidget {
  const _ConditionTile({
    required this.option,
    required this.accent,
    required this.isDark,
  });

  final ServiceConditionOption option;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCustom = ExperienceItemCodec.isCustom(option.id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.14 : 0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(option.icon, size: 16, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              option.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.88),
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: isDark ? 0.2 : 0.12),
            ),
            child: Icon(
              isCustom ? Icons.edit_note_rounded : Icons.check_rounded,
              size: 14,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

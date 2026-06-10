import 'package:flutter/material.dart';

import '../../../../../../../core/constants/app_strings.dart';
import '../../../../../../../shared/theme/app_colors.dart';
import '../../../../../../../shared/theme/app_fonts.dart';
import '../../../../../models/client_comfort_option.dart';
import '../../../../../models/experience_item_codec.dart';
import 'custom_add_panel.dart';
import 'experience_edit_shell.dart';

/// Carte d'édition des options de confort client.
class ComfortEditCard extends StatelessWidget {
  const ComfortEditCard({
    super.key,
    required this.selectedCount,
    required this.customLabels,
    required this.selectedIds,
    required this.onPresetToggled,
    required this.onCustomRemoved,
    required this.customController,
    required this.onAddCustom,
    this.flat = false,
  });

  final bool flat;
  final int selectedCount;
  final List<String> customLabels;
  final Set<String> selectedIds;
  final ValueChanged<String> onPresetToggled;
  final ValueChanged<String> onCustomRemoved;
  final TextEditingController customController;
  final VoidCallback onAddCustom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.tertiary;

    return ExperienceEditShell(
      flat: flat,
      accent: accent,
      isDark: isDark,
      icon: Icons.favorite_rounded,
      title: DiscPrestaComfort.sectionComfortTitle,
      subtitle: DiscPrestaComfort.sectionComfortHint,
      selectedCount: selectedCount,
      countLabel: (n) => '$n sélectionné${n > 1 ? 's' : ''}',
      gradientColors: isDark
          ? [accent.withValues(alpha: 0.10), accent.withValues(alpha: 0.04)]
          : [
              accent.withValues(alpha: 0.07),
              theme.colorScheme.tertiaryContainer.withValues(alpha: 0.18),
            ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in ClientComfortOption.presets)
                _SelectableComfortChip(
                  option: option,
                  accent: accent,
                  isDark: isDark,
                  selected: selectedIds.contains(option.id),
                  onTap: () => onPresetToggled(option.id),
                ),
              for (final label in customLabels)
                _SelectableComfortChip(
                  option: ClientComfortOption(
                    id: ExperienceItemCodec.encodeCustom(label),
                    label: label,
                    icon: Icons.star_outline_rounded,
                  ),
                  accent: accent,
                  isDark: isDark,
                  selected: true,
                  isCustom: true,
                  onTap: () => onCustomRemoved(label),
                ),
            ],
          ),
          const SizedBox(height: 14),
          CustomAddPanel(
            accent: accent,
            onAccent: theme.colorScheme.onTertiary,
            isDark: isDark,
            controller: customController,
            hint: DiscPrestaComfort.addCustomComfortHint,
            onAdd: onAddCustom,
          ),
        ],
      ),
    );
  }
}

class _SelectableComfortChip extends StatelessWidget {
  const _SelectableComfortChip({
    required this.option,
    required this.accent,
    required this.isDark,
    required this.selected,
    required this.onTap,
    this.isCustom = false,
  });

  final ClientComfortOption option;
  final Color accent;
  final bool isDark;
  final bool selected;
  final VoidCallback onTap;
  final bool isCustom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: isDark ? 0.22 : 0.14)
                : isDark
                ? theme.colorScheme.surface.withValues(alpha: 0.5)
                : theme.colorScheme.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: isDark ? 0.55 : 0.45)
                  : accent.withValues(alpha: isDark ? 0.2 : 0.14),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected && !isDark
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: accent.withValues(
                    alpha: selected
                        ? (isDark ? 0.28 : 0.18)
                        : (isDark ? 0.16 : 0.1),
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  option.icon,
                  size: 14,
                  color: selected ? accent : accent.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                option.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                Icon(
                  isCustom ? Icons.close_rounded : Icons.check_rounded,
                  size: 16,
                  color: accent,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

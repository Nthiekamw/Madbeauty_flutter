import 'package:flutter/material.dart';

import '../../../../../../../core/constants/app_strings.dart';
import '../../../../../../../shared/theme/app_colors.dart';
import '../../../../../../../shared/theme/app_fonts.dart';
import '../../../../../models/experience_item_codec.dart';
import '../../../../../models/service_condition_option.dart';
import 'custom_add_panel.dart';
import 'experience_edit_shell.dart';

/// Carte d'édition des conditions de service.
class ConditionsEditCard extends StatelessWidget {
  const ConditionsEditCard({
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
    final accent = theme.colorScheme.secondary;

    return ExperienceEditShell(
      flat: flat,
      accent: accent,
      isDark: isDark,
      icon: Icons.rule_rounded,
      title: DiscPrestaComfort.sectionConditionsTitle,
      subtitle: DiscPrestaComfort.sectionConditionsHint,
      selectedCount: selectedCount,
      countLabel: (n) => '$n sélectionnée${n > 1 ? 's' : ''}',
      useSurfaceBackground: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < ServiceConditionOption.presets.length; i++) ...[
            _SelectableConditionRow(
              option: ServiceConditionOption.presets[i],
              accent: accent,
              onAccent: theme.colorScheme.onSecondary,
              isDark: isDark,
              selected: selectedIds.contains(
                ServiceConditionOption.presets[i].id,
              ),
              onTap: () =>
                  onPresetToggled(ServiceConditionOption.presets[i].id),
            ),
            if (i < ServiceConditionOption.presets.length - 1)
              Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(
                  alpha: isDark ? 0.08 : 0.06,
                ),
              ),
          ],
          if (customLabels.isNotEmpty) ...[
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(
                alpha: isDark ? 0.08 : 0.06,
              ),
            ),
            for (var i = 0; i < customLabels.length; i++) ...[
              _SelectableConditionRow(
                option: ServiceConditionOption(
                  id: ExperienceItemCodec.encodeCustom(customLabels[i]),
                  label: customLabels[i],
                  icon: Icons.edit_note_rounded,
                ),
                accent: accent,
                onAccent: theme.colorScheme.onSecondary,
                isDark: isDark,
                selected: true,
                isCustom: true,
                onTap: () => onCustomRemoved(customLabels[i]),
              ),
              if (i < customLabels.length - 1)
                Divider(
                  height: 1,
                  color: theme.colorScheme.outline.withValues(
                    alpha: isDark ? 0.08 : 0.06,
                  ),
                ),
            ],
          ],
          const SizedBox(height: 14),
          CustomAddPanel(
            accent: accent,
            onAccent: theme.colorScheme.onSecondary,
            isDark: isDark,
            controller: customController,
            hint: DiscPrestaComfort.addCustomConditionHint,
            onAdd: onAddCustom,
          ),
        ],
      ),
    );
  }
}

class _SelectableConditionRow extends StatelessWidget {
  const _SelectableConditionRow({
    required this.option,
    required this.accent,
    required this.onAccent,
    required this.isDark,
    required this.selected,
    required this.onTap,
    this.isCustom = false,
  });

  final ServiceConditionOption option;
  final Color accent;
  final Color onAccent;
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 11),
          color: selected
              ? accent.withValues(alpha: isDark ? 0.06 : 0.04)
              : AppColors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(
                    alpha: selected
                        ? (isDark ? 0.22 : 0.14)
                        : (isDark ? 0.12 : 0.08),
                  ),
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
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(
                      alpha: selected ? 0.95 : 0.82,
                    ),
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? accent
                      : theme.colorScheme.outline.withValues(
                          alpha: isDark ? 0.2 : 0.15,
                        ),
                  border: selected
                      ? null
                      : Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: isDark ? 0.35 : 0.28,
                          ),
                          width: 1.5,
                        ),
                ),
                child: selected
                    ? Icon(
                        isCustom ? Icons.close_rounded : Icons.check_rounded,
                        size: 14,
                        color: onAccent,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

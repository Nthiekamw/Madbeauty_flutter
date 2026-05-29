import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_text_field.dart';
import '../../models/client_comfort_option.dart';
import '../../models/experience_item_codec.dart';
import '../../models/service_condition_option.dart';

class PrestataireProfileClientExperienceStep extends StatefulWidget {
  const PrestataireProfileClientExperienceStep({
    super.key,
    required this.selectedComfortIds,
    required this.selectedConditionIds,
    required this.onComfortToggled,
    required this.onConditionToggled,
    required this.onAddCustomComfort,
    required this.onAddCustomCondition,
    required this.onChanged,
  });

  final Set<String> selectedComfortIds;
  final Set<String> selectedConditionIds;
  final ValueChanged<String> onComfortToggled;
  final ValueChanged<String> onConditionToggled;
  final ValueChanged<String> onAddCustomComfort;
  final ValueChanged<String> onAddCustomCondition;
  final VoidCallback onChanged;

  @override
  State<PrestataireProfileClientExperienceStep> createState() =>
      _PrestataireProfileClientExperienceStepState();
}

class _PrestataireProfileClientExperienceStepState
    extends State<PrestataireProfileClientExperienceStep> {
  final _customComfortController = TextEditingController();
  final _customConditionController = TextEditingController();

  @override
  void dispose() {
    _customComfortController.dispose();
    _customConditionController.dispose();
    super.dispose();
  }

  void _addComfort() {
    final encoded =
        ExperienceItemCodec.encodeCustom(_customComfortController.text);
    if (encoded.isEmpty) return;
    widget.onAddCustomComfort(encoded);
    _customComfortController.clear();
    widget.onChanged();
  }

  void _addCondition() {
    final encoded =
        ExperienceItemCodec.encodeCustom(_customConditionController.text);
    if (encoded.isEmpty) return;
    widget.onAddCustomCondition(encoded);
    _customConditionController.clear();
    widget.onChanged();
  }

  int get _comfortCount => widget.selectedComfortIds.length;
  int get _conditionCount => widget.selectedConditionIds.length;

  @override
  Widget build(BuildContext context) {
    final customComforts = widget.selectedComfortIds
        .where(ExperienceItemCodec.isCustom)
        .map(ExperienceItemCodec.decodeCustomLabel)
        .where((l) => l.isNotEmpty)
        .toList();
    final customConditions = widget.selectedConditionIds
        .where(ExperienceItemCodec.isCustom)
        .map(ExperienceItemCodec.decodeCustomLabel)
        .where((l) => l.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ComfortEditCard(
          selectedCount: _comfortCount,
          customLabels: customComforts,
          selectedIds: widget.selectedComfortIds,
          onPresetToggled: (id) {
            widget.onComfortToggled(id);
            widget.onChanged();
          },
          onCustomRemoved: (label) {
            widget.onComfortToggled(ExperienceItemCodec.encodeCustom(label));
            widget.onChanged();
          },
          customController: _customComfortController,
          onAddCustom: _addComfort,
        ),
        const SizedBox(height: 20),
        _ConditionsEditCard(
          selectedCount: _conditionCount,
          customLabels: customConditions,
          selectedIds: widget.selectedConditionIds,
          onPresetToggled: (id) {
            widget.onConditionToggled(id);
            widget.onChanged();
          },
          onCustomRemoved: (label) {
            widget.onConditionToggled(ExperienceItemCodec.encodeCustom(label));
            widget.onChanged();
          },
          customController: _customConditionController,
          onAddCustom: _addCondition,
        ),
      ],
    );
  }
}

// ─── Carte confort (édition) ─────────────────────────────────────────────────

class _ComfortEditCard extends StatelessWidget {
  const _ComfortEditCard({
    required this.selectedCount,
    required this.customLabels,
    required this.selectedIds,
    required this.onPresetToggled,
    required this.onCustomRemoved,
    required this.customController,
    required this.onAddCustom,
  });

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

    return _ExperienceEditShell(
      accent: accent,
      isDark: isDark,
      icon: Icons.favorite_rounded,
      title: DiscPrestaComfort.sectionComfortTitle,
      subtitle: DiscPrestaComfort.sectionComfortHint,
      selectedCount: selectedCount,
      countLabel: (n) => '$n sélectionné${n > 1 ? 's' : ''}',
      gradientColors: isDark
          ? [
              accent.withValues(alpha: 0.10),
              accent.withValues(alpha: 0.04),
            ]
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
          _CustomAddPanel(
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
      color: Colors.transparent,
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

// ─── Carte conditions (édition) ──────────────────────────────────────────────

class _ConditionsEditCard extends StatelessWidget {
  const _ConditionsEditCard({
    required this.selectedCount,
    required this.customLabels,
    required this.selectedIds,
    required this.onPresetToggled,
    required this.onCustomRemoved,
    required this.customController,
    required this.onAddCustom,
  });

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

    return _ExperienceEditShell(
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
              selected: selectedIds.contains(ServiceConditionOption.presets[i].id),
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
          _CustomAddPanel(
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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 11),
          color: selected
              ? accent.withValues(alpha: isDark ? 0.06 : 0.04)
              : Colors.transparent,
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

// ─── Composants partagés ─────────────────────────────────────────────────────

class _ExperienceEditShell extends StatelessWidget {
  const _ExperienceEditShell({
    required this.accent,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selectedCount,
    required this.countLabel,
    required this.child,
    this.gradientColors,
    this.useSurfaceBackground = false,
  });

  final Color accent;
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final int selectedCount;
  final String Function(int count) countLabel;
  final Widget child;
  final List<Color>? gradientColors;
  final bool useSurfaceBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: gradientColors != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors!,
              )
            : null,
        color: useSurfaceBackground
            ? theme.colorScheme.surface.withValues(alpha: isDark ? 0.6 : 0.95)
            : null,
        border: Border.all(
          color: useSurfaceBackground
              ? theme.colorScheme.outline.withValues(
                  alpha: isDark ? 0.14 : 0.09,
                )
              : accent.withValues(alpha: isDark ? 0.18 : 0.14),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: accent.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontFamily: AppFonts.display,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                          if (selectedCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(
                                  alpha: isDark ? 0.2 : 0.12,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                countLabel(selectedCount),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontFamily: AppFonts.body,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: AppFonts.body,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _CustomAddPanel extends StatelessWidget {
  const _CustomAddPanel({
    required this.accent,
    required this.onAccent,
    required this.isDark,
    required this.controller,
    required this.hint,
    required this.onAdd,
    this.multiline = false,
  });

  final Color accent;
  final Color onAccent;
  final bool isDark;
  final TextEditingController controller;
  final String hint;
  final VoidCallback onAdd;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.35 : 0.55,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.12 : 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            multiline ? CrossAxisAlignment.end : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: AppTextField(
              controller: controller,
              hint: hint,
              maxLines: multiline ? 2 : 1,
              borderRadius: 12,
              prefixIcon: Icon(
                Icons.add_rounded,
                size: 20,
                color: accent.withValues(alpha: 0.8),
              ),
              onSubmitted: (_) => onAdd(),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: onAccent,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(DiscPrestaComfort.addAction),
          ),
        ],
      ),
    );
  }
}

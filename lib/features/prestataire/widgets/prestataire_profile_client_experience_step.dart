import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../models/client_comfort_option.dart';
import '../models/experience_item_codec.dart';
import '../models/service_condition_option.dart';

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
    final encoded = ExperienceItemCodec.encodeCustom(_customComfortController.text);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        Text(
          DiscPrestaComfort.sectionComfortTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          DiscPrestaComfort.sectionComfortHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in ClientComfortOption.presets)
              FilterChip(
                label: Text(option.label),
                avatar: Icon(option.icon, size: 18),
                selected: widget.selectedComfortIds.contains(option.id),
                onSelected: (_) {
                  widget.onComfortToggled(option.id);
                  widget.onChanged();
                },
                showCheckmark: true,
              ),
          ],
        ),
        if (customComforts.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final label in customComforts)
                InputChip(
                  label: Text(label),
                  onDeleted: () {
                    final id = ExperienceItemCodec.encodeCustom(label);
                    widget.onComfortToggled(id);
                    widget.onChanged();
                  },
                ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: _customComfortController,
                label: DiscPrestaComfort.addCustomComfortLabel,
                hint: DiscPrestaComfort.addCustomComfortHint,
                onSubmitted: (_) => _addComfort(),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 22),
              child: FilledButton.tonal(
                onPressed: _addComfort,
                child: const Text(DiscPrestaComfort.addAction),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          DiscPrestaComfort.sectionConditionsTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          DiscPrestaComfort.sectionConditionsHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in ServiceConditionOption.presets)
              FilterChip(
                label: Text(option.label),
                selected: widget.selectedConditionIds.contains(option.id),
                onSelected: (_) {
                  widget.onConditionToggled(option.id);
                  widget.onChanged();
                },
                showCheckmark: true,
              ),
          ],
        ),
        if (customConditions.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final label in customConditions)
                InputChip(
                  label: Text(label),
                  onDeleted: () {
                    final id = ExperienceItemCodec.encodeCustom(label);
                    widget.onConditionToggled(id);
                    widget.onChanged();
                  },
                ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: _customConditionController,
                label: DiscPrestaComfort.addCustomConditionLabel,
                hint: DiscPrestaComfort.addCustomConditionHint,
                maxLines: 2,
                onSubmitted: (_) => _addCondition(),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 22),
              child: FilledButton.tonal(
                onPressed: _addCondition,
                child: const Text(DiscPrestaComfort.addAction),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

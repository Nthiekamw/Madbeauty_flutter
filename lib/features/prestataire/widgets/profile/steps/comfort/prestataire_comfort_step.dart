import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../models/experience_item_codec.dart';
import '../../hub/prestataire_hub_layout.dart';
import 'client_experience/comfort_edit_card.dart';
import 'client_experience/conditions_edit_card.dart';

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
    this.embeddedInHub = false,
  });

  final Set<String> selectedComfortIds;
  final Set<String> selectedConditionIds;
  final ValueChanged<String> onComfortToggled;
  final ValueChanged<String> onConditionToggled;
  final ValueChanged<String> onAddCustomComfort;
  final ValueChanged<String> onAddCustomCondition;
  final VoidCallback onChanged;
  final bool embeddedInHub;

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
    final encoded = ExperienceItemCodec.encodeCustom(
      _customComfortController.text,
    );
    if (encoded.isEmpty) return;
    widget.onAddCustomComfort(encoded);
    _customComfortController.clear();
    widget.onChanged();
  }

  void _addCondition() {
    final encoded = ExperienceItemCodec.encodeCustom(
      _customConditionController.text,
    );
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

    final comfortCard = ComfortEditCard(
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
      flat: widget.embeddedInHub,
    );
    final conditionsCard = ConditionsEditCard(
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
      flat: widget.embeddedInHub,
    );

    if (!widget.embeddedInHub) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          comfortCard,
          const SizedBox(height: 12),
          conditionsCard,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrestataireHubMetricBanner(
          icon: Icons.favorite_rounded,
          label: 'Confort & conditions',
          value: '${_comfortCount + _conditionCount} choix',
        ),
        const SizedBox(height: PrestataireHubLayout.sectionGap),
        PrestataireHubFormSection(
          index: 1,
          title: DiscPrestaComfort.sectionComfortTitle,
          subtitle: DiscPrestaComfort.sectionComfortHint,
          icon: Icons.favorite_rounded,
          child: comfortCard,
        ),
        const SizedBox(height: PrestataireHubLayout.sectionGap),
        PrestataireHubFormSection(
          index: 2,
          title: DiscPrestaComfort.sectionConditionsTitle,
          subtitle: DiscPrestaComfort.sectionConditionsHint,
          icon: Icons.rule_rounded,
          child: conditionsCard,
        ),
      ],
    );
  }
}

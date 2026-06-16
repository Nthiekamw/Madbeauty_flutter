import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../shared/widgets/app/app_text_field.dart';
import '../../../../logic/prestataire_service_duration_options.dart';
import 'service_wizard_shine.dart';

/// Sélecteur de durée : 30 min, 1 h, 1 h 30, 2 h ou durée personnalisée.
class PrestataireServiceDurationField extends StatefulWidget {
  const PrestataireServiceDurationField({
    super.key,
    required this.controller,
    this.errorText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String? errorText;
  final VoidCallback onChanged;

  @override
  State<PrestataireServiceDurationField> createState() =>
      _PrestataireServiceDurationFieldState();
}

class _PrestataireServiceDurationFieldState
    extends State<PrestataireServiceDurationField> {
  late final TextEditingController _customController;
  var _customMode = false;

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController();
    _syncFromController();
    widget.controller.addListener(_syncFromController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromController);
    _customController.dispose();
    super.dispose();
  }

  void _syncFromController() {
    final minutes = parsePrestataireServiceDuration(widget.controller.text);
    if (minutes == null || minutes <= 0) {
      if (_customMode) return;
      setState(() => _customMode = false);
      return;
    }
    if (PrestataireServiceDurationOptions.isPreset(minutes)) {
      if (_customMode) {
        setState(() => _customMode = false);
      }
      return;
    }
    if (!_customMode || _customController.text != '$minutes') {
      _customController.text = '$minutes';
    }
    if (!_customMode) {
      setState(() => _customMode = true);
    }
  }

  void _selectPreset(int minutes) {
    setState(() => _customMode = false);
    widget.controller.text = '$minutes';
    widget.onChanged();
  }

  void _enableCustom() {
    setState(() => _customMode = true);
    final current = parsePrestataireServiceDuration(widget.controller.text);
    if (current != null &&
        !PrestataireServiceDurationOptions.isPreset(current)) {
      _customController.text = '$current';
    } else {
      _customController.clear();
      widget.controller.clear();
    }
    widget.onChanged();
  }

  void _onCustomChanged(String value) {
    widget.controller.text = value.trim();
    widget.onChanged();
  }

  int? get _selectedPreset {
    final minutes = parsePrestataireServiceDuration(widget.controller.text);
    if (minutes == null || !PrestataireServiceDurationOptions.isPreset(minutes)) {
      return null;
    }
    return minutes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedPreset = _selectedPreset;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DiscPrestaForm.svcDuration,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final minutes in PrestataireServiceDurationOptions.presetMinutes)
              ChoiceChip(
                label: Text(
                  PrestataireServiceDurationOptions.labelForMinutes(minutes),
                ),
                selected: !_customMode && selectedPreset == minutes,
                onSelected: (_) => _selectPreset(minutes),
              ),
            ChoiceChip(
              label: Text(DiscPrestaForm.svcDurationMore),
              selected: _customMode,
              onSelected: (_) => _enableCustom(),
            ),
          ],
        ),
        if (_customMode) ...[
          const SizedBox(height: 10),
          AppTextField(
            controller: _customController,
            label: DiscPrestaForm.svcDurationCustomHint,
            errorText: widget.errorText,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: _onCustomChanged,
          ),
        ] else if (widget.errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

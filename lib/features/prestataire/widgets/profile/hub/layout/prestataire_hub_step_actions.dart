import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../shared/layout/discovery_responsive.dart';
import 'prestataire_hub_layout_core.dart';

/// Boutons de navigation en bas d'étape.
class PrestataireHubStepActions extends StatelessWidget {
  const PrestataireHubStepActions({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    required this.saving,
    this.onBack,
    this.onSkip,
    this.onCompleteLater,
    this.showSkip = false,
    this.showCompleteLater = false,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool saving;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;
  final VoidCallback? onCompleteLater;
  final bool showSkip;
  final bool showCompleteLater;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layout = DiscoveryResponsive.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: saving ? null : onPrimary,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: PrestataireHubLayout.cardRadius,
            ),
          ),
          child: Text(
            primaryLabel,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
        if (onBack != null || showSkip || showCompleteLater) ...[
          const SizedBox(height: PrestataireHubLayout.actionGap),
          if (layout.stackStepperActions)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _secondaryActions(theme),
            )
          else
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: _secondaryActions(theme),
            ),
        ],
      ],
    );
  }

  List<Widget> _secondaryActions(ThemeData theme) {
    return [
      if (onBack != null)
        TextButton(
          onPressed: saving ? null : onBack,
          child: const Text(DiscPrestaForm.back),
        ),
      if (showSkip && onSkip != null)
        OutlinedButton.icon(
          onPressed: saving ? null : onSkip,
          icon: const Icon(Icons.fast_forward_rounded, size: 16),
          label: const Text(DiscPrestaForm.skipStep),
        ),
      if (showCompleteLater && onCompleteLater != null)
        FilledButton.tonalIcon(
          onPressed: saving ? null : onCompleteLater,
          icon: const Icon(Icons.schedule_outlined, size: 16),
          label: const Text(DiscPrestaForm.completeLater),
        ),
    ];
  }
}

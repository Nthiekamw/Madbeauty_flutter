import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../shared/theme/app_fonts.dart';

/// Légende sous la barre de progression (étape courante + nom).
class PrestataireHubWizardStepCaption extends StatelessWidget {
  const PrestataireHubWizardStepCaption({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitle,
  });

  final int currentStep;
  final int totalSteps;
  final String stepTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Row(
      children: [
        Text(
          DiscPrestaForm.hubWizardProgressLabel(
            currentStep + 1,
            totalSteps,
          ),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: onSurface.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '·',
          style: theme.textTheme.labelMedium?.copyWith(
            color: onSurface.withValues(alpha: 0.35),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            stepTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
              color: onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// Barre de progression segmentée (7 étapes).
class PrestataireHubWizardProgress extends StatelessWidget {
  const PrestataireHubWizardProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.saving,
  });

  final int currentStep;
  final int totalSteps;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Row(
      children: [
        for (var i = 0; i < totalSteps; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i <= currentStep
                    ? primary
                    : theme.colorScheme.outline.withValues(alpha: 0.18),
              ),
            ),
          ),
          if (i < totalSteps - 1) const SizedBox(width: 4),
        ],
        if (saving) ...[
          const SizedBox(width: 10),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: primary),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';

/// Barre de progression linéaire + libellé d’étape (wizard inscription).
class RegisterWizardProgressBar extends StatelessWidget {
  const RegisterWizardProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabel,
    this.compact = false,
  });

  final int currentStep;
  final int totalSteps;
  final String stepLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final progress = (currentStep + 1) / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              AuthStrings.registerStepCounter(currentStep + 1, totalSteps),
              style: theme.textTheme.labelMedium?.copyWith(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                stepLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 6 : 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0, end: progress),
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: compact ? 4 : 5,
                backgroundColor:
                    theme.colorScheme.outline.withValues(alpha: 0.2),
                color: primary,
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';

/// Barre de progression du parcours guidé (étapes 1…[totalSteps]).
class PrestataireCompletionProgress extends StatelessWidget {
  const PrestataireCompletionProgress({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.stepLabel,
  });

  final int stepIndex;
  final int totalSteps;
  final String stepLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = stepIndex / totalSteps;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '${DiscPrestaCompletion.stepOf} $stepIndex / $totalSteps',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              Text(
                stepLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: DiscoveryStyles.chipBorderRadius,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor:
                  theme.colorScheme.outline.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

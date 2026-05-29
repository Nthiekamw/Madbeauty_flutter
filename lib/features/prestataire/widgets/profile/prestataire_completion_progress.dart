import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/discovery_styles.dart';

/// Jalons visuels + barre pour le parcours guidé prestataire.
class PrestataireCompletionProgress extends StatelessWidget {
  const PrestataireCompletionProgress({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.stepLabel,
  });

  /// Indice affiché 1 … [totalSteps] (sans l’intro 0).
  final int stepIndex;
  final int totalSteps;
  final String stepLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = stepIndex / totalSteps;
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '${DiscPrestaCompletion.stepOf} $stepIndex — $stepLabel',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$stepIndex/$totalSteps',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 1; i <= totalSteps; i++) ...[
                if (i > 1) Expanded(child: _StepConnector(done: stepIndex >= i)),
                _StepOrb(
                  index: i,
                  done: stepIndex > i,
                  active: stepIndex == i,
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: DiscoveryStyles.chipBorderRadius,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor:
                  theme.colorScheme.outline.withValues(alpha: 0.12),
              color: primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = done
        ? theme.colorScheme.primary
        : theme.colorScheme.outline.withValues(alpha: 0.35);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Center(
        child: Container(
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: color,
          ),
        ),
      ),
    );
  }
}

class _StepOrb extends StatelessWidget {
  const _StepOrb({
    required this.index,
    required this.done,
    required this.active,
  });

  final int index;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final bgColor = done || active ? primary : theme.colorScheme.surfaceContainerHighest;

    final borderColor = active
        ? theme.colorScheme.tertiary
        : (done ? primary.withValues(alpha: 0.3) : theme.colorScheme.outline.withValues(alpha: 0.25));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: active ? 30 : 28,
      height: active ? 30 : 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: Border.all(
          width: active ? 2.5 : 1.5,
          color: active ? theme.colorScheme.tertiary : borderColor,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: 0.38),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: done
          ? const Icon(
              Icons.check_rounded,
              size: 15,
              color: Colors.white,
            )
          : active
              ? Text(
                  '$index',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                )
              : Text(
                  '$index',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1,
                  ),
                ),
    );
  }
}

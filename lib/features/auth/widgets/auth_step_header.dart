import 'package:flutter/material.dart';

import '../../../shared/theme/app_fonts.dart';

/// Indicateur d'étapes (inscription wizard).
class AuthStepHeader extends StatelessWidget {
  const AuthStepHeader({
    super.key,
    required this.currentStep,
    required this.labels,
  });

  final int currentStep;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(labels.length * 2 - 1, (index) {
            if (index.isOdd) {
              final stepBefore = index ~/ 2;
              final done = stepBefore < currentStep;
              return Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 22),
                  color: done
                      ? primary.withValues(alpha: 0.55)
                      : theme.colorScheme.outline.withValues(alpha: 0.25),
                ),
              );
            }

            final stepIndex = index ~/ 2;
            final active = stepIndex == currentStep;
            final done = stepIndex < currentStep;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: active ? 36 : 32,
                  height: active ? 36 : 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done || active
                        ? primary
                        : theme.colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: active
                          ? primary
                          : theme.colorScheme.outline.withValues(alpha: 0.35),
                      width: active ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: done
                      ? Icon(
                          Icons.check,
                          size: 18,
                          color: theme.colorScheme.onPrimary,
                        )
                      : Text(
                          '${stepIndex + 1}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                            color: active
                                ? theme.colorScheme.onPrimary
                                : muted,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 88,
                  child: Text(
                    labels[stepIndex],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontFamily: AppFonts.body,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? primary : muted,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}


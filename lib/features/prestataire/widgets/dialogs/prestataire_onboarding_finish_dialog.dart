import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

/// Récapitulatif après enregistrement du wizard : profil catalogue vs enrichissements.
Future<void> showPrestataireOnboardingFinishDialog({
  required BuildContext context,
  required bool professionallyComplete,
  required List<String> requiredMissing,
  required List<String> optionalMissing,
  required VoidCallback onCompleteProfile,
}) {
  final hasRequired = requiredMissing.isNotEmpty;
  final hasOptional = optionalMissing.isNotEmpty;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return AlertDialog(
        title: Text(
          professionallyComplete && !hasOptional
              ? DiscPrestaForm.onboardingFinishCompleteTitle
              : DiscPrestaForm.onboardingFinishIncompleteTitle,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                professionallyComplete
                    ? DiscPrestaForm.onboardingFinishIncompleteBodyOk
                    : DiscPrestaForm.onboardingFinishIncompleteBodyRequired,
                style: theme.textTheme.bodyMedium,
              ),
              if (hasRequired) ...[
                const SizedBox(height: 12),
                Text(
                  DiscPrestaForm.onboardingFinishRequiredHeading,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                ...requiredMissing.map(
                  (label) => _OnboardingFinishBulletRow(
                    label: label,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              if (hasOptional) ...[
                const SizedBox(height: 12),
                Text(
                  DiscPrestaForm.onboardingFinishOptionalHeading,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                ...optionalMissing.map(
                  (label) => _OnboardingFinishBulletRow(label: label),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!professionallyComplete || hasOptional)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(DiscPrestaForm.onboardingFinishLater),
            ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onCompleteProfile();
            },
            child: Text(
              professionallyComplete
                  ? DiscPrestaForm.onboardingFinishEnrichCta
                  : DiscPrestaForm.onboardingFinishCompleteCta,
            ),
          ),
        ],
      );
    },
  );
}

class _OnboardingFinishBulletRow extends StatelessWidget {
  const _OnboardingFinishBulletRow({
    required this.label,
    this.color,
  });

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = color ?? theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 8),
            child: Icon(
              Icons.circle,
              size: 6,
              color: textColor.withValues(alpha: 0.72),
            ),
          ),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}


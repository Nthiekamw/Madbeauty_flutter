import 'package:flutter/material.dart';

/// Variante visuelle du bouton (rempli vs contour).
enum AppButtonVariant {
  primary,
  secondary,
}

/// Bouton standard MadBeauty : reprend le padding du thème pour les actions
/// principales (primary) et les actions secondaires (secondary / contour).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveOnPressed =
        (isLoading || !enabled) ? null : onPressed;

    final content = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.primary
                  ? colorScheme.onPrimary
                  : colorScheme.primary,
            ),
          )
        : child;

    return switch (variant) {
      AppButtonVariant.primary => FilledButton(
          onPressed: effectiveOnPressed,
          child: content,
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.primary,
            side: BorderSide(color: colorScheme.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          child: content,
        ),
    };
  }
}

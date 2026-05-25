import 'package:flutter/material.dart';

import '../theme/prototype_layout.dart';
import '../theme/prototype_palette.dart';
import 'app_text_field.dart';

/// Barre de recherche sur fond brand (accueil, catalogue).
class DiscoverySearchCard extends StatelessWidget {
  const DiscoverySearchCard({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onSubmitted,
    this.suffixIcon,
    this.compact = false,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final Widget? suffixIcon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final rem = PrototypeLayout(context).rem;
    final radius = BorderRadius.circular(rem * (compact ? 8 : 8));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface.withValues(alpha: 0.94)
            : PrototypePalette.cardWhite,
        borderRadius: radius,
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outline.withValues(alpha: 0.14)
              : PrototypePalette.goldLight.withValues(alpha: 0.6),
        ),
        boxShadow: isDark ? null : PrototypePalette.cardShadow(opacity: 0.07),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          rem * 1.2,
          rem * (compact ? 0.8 : 1),
          rem * 1.2,
          rem * (compact ? 0.8 : 1),
        ),
        child: AppTextField(
          controller: controller,
          hint: hint,
          textInputAction: TextInputAction.search,
          borderRadius: rem * 6,
          onChanged: onChanged,
          onSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark
                ? theme.colorScheme.onSurfaceVariant
                : PrototypePalette.textGrey,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../shared/theme/app_fonts.dart';

/// Puces de suggestion (expérience pro, années, etc.).
class PrestataireSuggestionChips extends StatelessWidget {
  const PrestataireSuggestionChips({
    super.key,
    required this.label,
    required this.options,
    required this.onSelected,
    this.selectedValue,
  });

  final String label;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final selected = selectedValue?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              FilterChip(
                label: Text(option),
                selected: selected == option,
                showCheckmark: false,
                onSelected: (_) => onSelected(option),
                selectedColor: primary.withValues(alpha: 0.18),
                checkmarkColor: primary,
                labelStyle: theme.textTheme.labelLarge?.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: selected == option ? FontWeight.w700 : FontWeight.w500,
                  color: selected == option ? primary : null,
                ),
                side: BorderSide(
                  color: selected == option
                      ? primary.withValues(alpha: 0.45)
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

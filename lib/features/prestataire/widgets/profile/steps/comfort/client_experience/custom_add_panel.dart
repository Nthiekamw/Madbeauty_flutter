import 'package:flutter/material.dart';

import '../../../../../../../core/constants/app_strings.dart';
import '../../../../../../../shared/widgets/app/app_text_field.dart';

/// Champ texte + bouton pour ajouter un élément personnalisé.
class CustomAddPanel extends StatelessWidget {
  const CustomAddPanel({
    super.key,
    required this.accent,
    required this.onAccent,
    required this.isDark,
    required this.controller,
    required this.hint,
    required this.onAdd,
    this.multiline = false,
  });

  final Color accent;
  final Color onAccent;
  final bool isDark;
  final TextEditingController controller;
  final String hint;
  final VoidCallback onAdd;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.35 : 0.55,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.12 : 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: multiline
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: AppTextField(
              controller: controller,
              hint: hint,
              maxLines: multiline ? 2 : 1,
              borderRadius: 12,
              prefixIcon: Icon(
                Icons.add_rounded,
                size: 20,
                color: accent.withValues(alpha: 0.8),
              ),
              onSubmitted: (_) => onAdd(),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: onAccent,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(DiscPrestaComfort.addAction),
          ),
        ],
      ),
    );
  }
}

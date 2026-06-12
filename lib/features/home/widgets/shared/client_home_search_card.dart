import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';

/// Barre de recherche + bouton filtres (accueil client).
class ClientHomeSearchCard extends StatelessWidget {
  const ClientHomeSearchCard({
    super.key,
    required this.controller,
    required this.hint,
    required this.searchTooltip,
    required this.onSubmit,
    this.onChanged,
    this.onFilter,
  });

  final TextEditingController controller;
  final String hint;
  final String searchTooltip;
  final VoidCallback onSubmit;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(
                alpha: isDark ? 0.94 : 0.98,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
              ),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: (_) => onSubmit(),
              textInputAction: TextInputAction.search,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12.5,
                fontFamily: AppFonts.body,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.85),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 36,
                ),
              ),
            ),
          ),
        ),
        if (onFilter != null) ...[
          const SizedBox(width: 8),
          Material(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onFilter,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: isDark
                      ? AppColors.onPrimaryDarkText
                      : theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

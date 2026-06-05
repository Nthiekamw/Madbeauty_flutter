import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/models/domain/catalog/service_category.dart';

class PrestataireProfileSpecialtiesStep extends StatelessWidget {
  const PrestataireProfileSpecialtiesStep({
    super.key,
    required this.categories,
    required this.selectedCategoryIds,
    required this.errorText,
    required this.onToggle,
  });

  final List<ServiceCategory> categories;
  final Set<String> selectedCategoryIds;
  final String? errorText;
  final void Function(String id, bool selected) onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(DiscPrestaForm.specialtiesHint, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in categories)
              FilterChip(
                label: Text(category.nom),
                selected: selectedCategoryIds.contains(category.id),
                onSelected: (selected) => onToggle(category.id, selected),
              ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

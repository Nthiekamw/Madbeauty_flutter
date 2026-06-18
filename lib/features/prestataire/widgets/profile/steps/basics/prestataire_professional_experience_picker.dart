import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../shared/theme/app_fonts.dart';
import '../../../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../../logic/professional_experience_entries.dart';

class PrestataireProfessionalExperiencePicker extends StatelessWidget {
  const PrestataireProfessionalExperiencePicker({
    super.key,
    required this.entries,
    required this.errorText,
    required this.onToggleRole,
    required this.onYearsChanged,
    required this.onRemove,
  });

  final List<ProfessionalExperienceEntry> entries;
  final String? errorText;
  final ValueChanged<String> onToggleRole;
  final void Function(String role, String years) onYearsChanged;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final selectedRoles = entries.map((e) => e.role).toSet();
    final availableSuggestions = DiscPrestaForm.experienceProSuggestions
        .where((s) => !selectedRoles.contains(s))
        .toList();
    final canAddMore =
        entries.length < ProfessionalExperienceCodec.maxEntries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DiscPrestaForm.experiencePro,
          style: theme.textTheme.titleSmall?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DiscPrestaForm.experienceProMultiHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        if (entries.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (final entry in entries) ...[
            DiscoverySurfaceCard(
              includeHorizontalMargin: false,
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          entry.role,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _yearsValueFor(entry.years),
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: DiscPrestaForm.experienceYears,
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: [
                            for (final option
                                in DiscPrestaForm.experienceYearsSuggestions)
                              DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            onYearsChanged(entry.role, value);
                          },
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: DiscPrestaForm.experienceProRemove,
                    onPressed: () => onRemove(entry.role),
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
        if (canAddMore && availableSuggestions.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            DiscPrestaForm.experienceProAddLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final suggestion in availableSuggestions)
                FilterChip(
                  label: Text(suggestion),
                  selected: false,
                  showCheckmark: false,
                  avatar: Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: primary,
                  ),
                  onSelected: (_) => onToggleRole(suggestion),
                ),
            ],
          ),
        ],
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

  String? _yearsValueFor(String years) {
    final trimmed = years.trim();
    if (trimmed.isEmpty) return null;
    return DiscPrestaForm.experienceYearsSuggestions.contains(trimmed)
        ? trimmed
        : null;
  }
}

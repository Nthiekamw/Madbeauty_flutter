import 'package:flutter/material.dart';

import '../../../../../../shared/theme/app_colors.dart';
import '../../../../../../shared/theme/app_fonts.dart';
import '../../../../logic/prestataire_services_grouping.dart';
import 'prestataire_detail_service_group_header.dart';

class PrestataireDetailSpecialtiesByService extends StatelessWidget {
  const PrestataireDetailSpecialtiesByService({
    super.key,
    required this.groups,
  });

  final List<PrestataireSpecialtyServiceGroup> groups;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < groups.length; i++) ...[
          PrestataireDetailServiceGroupHeader(
            title: groups[i].serviceTitle,
            main: groups[i].main,
            compact: i == 0,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final name in groups[i].specialtyNames)
                _SpecialtyChip(label: name, isDark: isDark),
            ],
          ),
          if (i < groups.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  const _SpecialtyChip({
    required this.label,
    required this.isDark,
  });

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fill = isDark
        ? AppColors.darkSurfaceContainerHigh
        : AppColors.filterChipInactive;
    final fg = isDark
        ? AppColors.darkOnSurface
        : AppColors.filterChipInactiveText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: fg,
        ),
      ),
    );
  }
}

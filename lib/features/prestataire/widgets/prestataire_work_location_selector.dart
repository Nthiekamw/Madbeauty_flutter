import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/user/lieu_travail.dart';
import '../../../shared/theme/app_fonts.dart';

class PrestataireWorkLocationSelector extends StatelessWidget {
  const PrestataireWorkLocationSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final LieuTravail? value;
  final ValueChanged<LieuTravail> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DiscPrestaForm.workLocationTitle,
          style: theme.textTheme.labelLarge?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        _Option(
          label: DiscPrestaForm.workLocationHome,
          icon: Icons.home_outlined,
          selected: value == LieuTravail.home,
          onTap: () => onChanged(LieuTravail.home),
        ),
        const SizedBox(height: 8),
        _Option(
          label: DiscPrestaForm.workLocationClient,
          icon: Icons.directions_walk_outlined,
          selected: value == LieuTravail.client,
          onTap: () => onChanged(LieuTravail.client),
        ),
        const SizedBox(height: 8),
        _Option(
          label: DiscPrestaForm.workLocationBoth,
          icon: Icons.swap_horiz_outlined,
          selected: value == LieuTravail.both,
          onTap: () => onChanged(LieuTravail.both),
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

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.55)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: colorScheme.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

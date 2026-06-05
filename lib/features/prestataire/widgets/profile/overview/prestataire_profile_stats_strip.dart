import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/theme/app_fonts.dart';
import 'prestataire_profile_insets.dart';

/// Bandeau stats compact (profil prestataire).
class PrestataireProfileStatsStrip extends StatelessWidget {
  const PrestataireProfileStatsStrip({
    super.key,
    required this.servicesCount,
    required this.specialtiesCount,
    required this.photosCount,
  });

  final int servicesCount;
  final int specialtiesCount;
  final int photosCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: PrestataireProfileInsets.page(context).copyWith(top: 10),
      child: Row(
        children: [
          Expanded(
            child: _CompactStatChip(
              icon: Icons.design_services_outlined,
              label: DiscPrestaProfile.statServices,
              value: '$servicesCount',
              accent: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CompactStatChip(
              icon: Icons.category_outlined,
              label: DiscPrestaProfile.statSpecialties,
              value: '$specialtiesCount',
              accent: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CompactStatChip(
              icon: Icons.photo_library_outlined,
              label: DiscPrestaProfile.statPhotos,
              value: '$photosCount',
              accent: theme.colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactStatChip extends StatelessWidget {
  const _CompactStatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            Icon(icon, size: 16, color: accent),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

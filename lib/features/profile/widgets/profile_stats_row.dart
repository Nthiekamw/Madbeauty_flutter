import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';

/// Statistiques profil (valeurs statiques pour l’instant).
class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key});

  static const int appointmentsCount = 12;
  static const int favoritesCount = 0;
  static const double averageRating = 4.8;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: _StatTile(
              label: DiscProfile.statAppointments,
              value: '$appointmentsCount',
              icon: Icons.event_available_rounded,
              color: primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatTile(
              label: DiscProfile.statFavorites,
              value: '$favoritesCount',
              icon: Icons.favorite_rounded,
              color: primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatTile(
              label: DiscProfile.statRating,
              value: averageRating.toStringAsFixed(1),
              icon: Icons.star_rounded,
              color: const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontFamily: AppFonts.body,
              fontSize: 10,
              height: 1.15,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

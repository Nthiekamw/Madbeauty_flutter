import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../favorites/providers/client_favorite_prestataire_ids_provider.dart';

/// Statistiques profil (favoris synchronisés avec Supabase).
class ProfileStatsRow extends ConsumerWidget {
  const ProfileStatsRow({super.key});

  static const int appointmentsCount = 12;
  static const double averageRating = 4.8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final favoritesCount = ref.watch(clientFavoritesCountProvider);

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
              onTap: () => context.pushClientFavorites(),
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
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final child = Container(
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

    if (onTap == null) return child;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}

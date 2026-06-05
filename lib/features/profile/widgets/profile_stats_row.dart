import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../services/supabase/booking/booking_service_providers.dart';
import '../../favorites/providers/client_favorite_prestataire_ids_provider.dart';
import '../../prestataire/providers/current_prestataire_provider.dart';
import '../../reviews/providers/prestataire_note_moyenne_provider.dart';
import '../../../shared/theme/app_colors.dart';

/// Statistiques profil (favoris synchronisés avec Supabase).
class ProfileStatsRow extends ConsumerWidget {
  const ProfileStatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final appointmentsValue = switch (ref.watch(clientReservationsProvider)) {
      AsyncData(:final value) => '${value.length}',
      _ => '…',
    };
    final favoritesValue = switch (ref.watch(clientFavoritePrestataireIdsProvider)) {
      AsyncData(:final value) => '${value.length}',
      _ => '…',
    };
    final prestaId = switch (ref.watch(currentPrestataireProvider)) {
      AsyncData(:final value) => value?.id,
      _ => null,
    };
    final ratingValue = prestaId == null
        ? '–'
        : switch (ref.watch(prestataireNoteMoyenneProvider(prestaId))) {
            AsyncData(:final value) => value?.toStringAsFixed(1) ?? '–',
            _ => '…',
          };

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Expanded(
            child: _StatTile(
              label: DiscProfile.statAppointments,
              value: appointmentsValue,
              icon: Icons.event_available_rounded,
              color: primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatTile(
              label: DiscProfile.statFavorites,
              value: favoritesValue,
              icon: Icons.favorite_rounded,
              color: primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatTile(
              label: DiscProfile.statRating,
              value: ratingValue,
              icon: Icons.star_rounded,
              color: AppColors.starRating,
            ),
          ),
        ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 4),
          SizedBox(
            height: 26,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: AppFonts.body,
                    fontSize: 10,
                    height: 1.1,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


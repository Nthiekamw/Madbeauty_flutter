import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/models/domain/availability/horaire_plage.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../models/weekly_jour_horaire.dart';

/// Horaires hebdomadaires en lecture seule (fiche publique).
class PrestatairePublicHorairesSection extends StatelessWidget {
  const PrestatairePublicHorairesSection({
    super.key,
    required this.horaires,
  });

  final List<HorairePlage> horaires;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jours = WeeklyJourHoraire.fromPlages(horaires);
    final hasOpen = jours.any((j) => j.enabled);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!hasOpen)
          _HorairesEmptyCard(theme: theme)
        else
          ...[
            for (var i = 0; i < jours.length; i++) ...[
              _JourRow(
                label: DiscPrestaHoraires.jours[i],
                jour: jours[i],
              ),
              if (i < jours.length - 1) const SizedBox(height: 8),
            ],
          ],
      ],
    );
  }
}

class _HorairesEmptyCard extends StatelessWidget {
  const _HorairesEmptyCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DiscPrestaDetail.horairesEmptyTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DiscPrestaDetail.horairesEmptyBody,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JourRow extends StatelessWidget {
  const _JourRow({required this.label, required this.jour});

  final String label;
  final WeeklyJourHoraire jour;

  String _format(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              jour.enabled
                  ? '${_format(jour.debut)} — ${_format(jour.fin)}'
                  : DiscPrestaHoraires.dayOff,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: AppFonts.body,
                color: jour.enabled
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: jour.enabled ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          if (jour.enabled) ...[
            const SizedBox(width: 8),
            Icon(Icons.check_circle_outline, size: 18, color: primary),
          ],
        ],
      ),
    );
  }
}


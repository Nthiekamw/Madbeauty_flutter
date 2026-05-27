import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../models/weekly_jour_horaire.dart';

/// Éditeur des plages horaires hebdomadaires (wizard ou écran dédié).
class PrestataireWeeklyHorairesEditor extends StatelessWidget {
  const PrestataireWeeklyHorairesEditor({
    super.key,
    required this.jours,
    required this.errorText,
    required this.onToggleDay,
    required this.onPickStart,
    required this.onPickEnd,
    this.showIntro = true,
  });

  final List<WeeklyJourHoraire> jours;
  final String? errorText;
  final void Function(int index, bool enabled) onToggleDay;
  final Future<void> Function(int index) onPickStart;
  final Future<void> Function(int index) onPickEnd;
  final bool showIntro;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showIntro)
          Text(
            DiscPrestaHoraires.intro,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        if (errorText != null) ...[
          if (showIntro) const SizedBox(height: 12),
          Text(
            errorText!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        if (showIntro || errorText != null) const SizedBox(height: 16),
        for (var i = 0; i < jours.length; i++) ...[
          _JourHoraireCard(
            label: DiscPrestaHoraires.jours[i],
            jour: jours[i],
            onToggle: (v) => onToggleDay(i, v),
            onPickStart: () => onPickStart(i),
            onPickEnd: () => onPickEnd(i),
          ),
          if (i < jours.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _JourHoraireCard extends StatelessWidget {
  const _JourHoraireCard({
    required this.label,
    required this.jour,
    required this.onToggle,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final String label;
  final WeeklyJourHoraire jour;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  String _format(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Switch(value: jour.enabled, onChanged: onToggle),
              ],
            ),
            if (jour.enabled) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onPickStart,
                      child: Text(
                        '${DiscPrestaHoraires.heureDebut} ${_format(jour.debut)}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onPickEnd,
                      child: Text(
                        '${DiscPrestaHoraires.heureFin} ${_format(jour.fin)}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: jour.capaciteSimultanee,
                decoration: const InputDecoration(
                  labelText: DiscPrestaHoraires.capacite,
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1 personne')),
                  DropdownMenuItem(value: 2, child: Text('2 personnes')),
                  DropdownMenuItem(value: 3, child: Text('3 personnes')),
                  DropdownMenuItem(value: 4, child: Text('4 personnes')),
                  DropdownMenuItem(value: 5, child: Text('5 personnes')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  jour.capaciteSimultanee = value;
                },
              ),
            ] else
              Text(
                DiscPrestaHoraires.dayOff,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

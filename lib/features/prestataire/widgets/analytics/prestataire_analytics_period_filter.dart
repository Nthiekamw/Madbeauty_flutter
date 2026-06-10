import 'package:flutter/material.dart';

import '../../models/prestataire_analytics_period.dart';

/// Sélecteur de période (semaine / mois / année).
class PrestataireAnalyticsPeriodFilter extends StatelessWidget {
  const PrestataireAnalyticsPeriodFilter({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final PrestataireAnalyticsPeriod selected;
  final ValueChanged<PrestataireAnalyticsPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PrestataireAnalyticsPeriod>(
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
      ),
      segments: [
        for (final p in PrestataireAnalyticsPeriod.values)
          ButtonSegment(
            value: p,
            label: Text(
              p.label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
      ],
      selected: {selected},
      onSelectionChanged: (set) => onSelected(set.first),
    );
  }
}

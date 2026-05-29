import 'package:flutter/material.dart';

import '../../../../shared/theme/app_fonts.dart';

/// Tuile de métrique (bandeaux dashboard, agenda, profil).
class PrestataireMetricTile extends StatelessWidget {
  const PrestataireMetricTile({
    super.key,
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
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: isDark ? 0.22 : 0.14),
            theme.colorScheme.surface.withValues(alpha: isDark ? 0.55 : 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: accent),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontFamily: AppFonts.body,
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

/// Rangée de 3 métriques alignées sur le design agenda.
class PrestataireMetricStrip extends StatelessWidget {
  const PrestataireMetricStrip({
    super.key,
    required this.metrics,
    this.padding = const EdgeInsets.fromLTRB(20, 4, 20, 0),
  });

  final List<PrestataireMetricTile> metrics;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    assert(metrics.length == 3, 'PrestataireMetricStrip attend 3 métriques');

    return Padding(
      padding: padding,
      child: Row(
        children: [
          for (var i = 0; i < metrics.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: metrics[i]),
          ],
        ],
      ),
    );
  }
}

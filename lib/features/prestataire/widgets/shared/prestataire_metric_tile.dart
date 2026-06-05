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
            accent.withValues(alpha: isDark ? 0.28 : 0.16),
            theme.colorScheme.surface.withValues(alpha: isDark ? 0.5 : 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: accent.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: accent),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontFamily: AppFonts.body,
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
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
    this.padding = EdgeInsets.zero,
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


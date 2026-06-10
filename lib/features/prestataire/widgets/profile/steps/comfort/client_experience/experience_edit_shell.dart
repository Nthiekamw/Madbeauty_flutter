import 'package:flutter/material.dart';

import '../../../../../../../shared/theme/app_fonts.dart';

/// Enveloppe visuelle commune confort / conditions (hors mode hub « flat »).
class ExperienceEditShell extends StatelessWidget {
  const ExperienceEditShell({
    super.key,
    required this.accent,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selectedCount,
    required this.countLabel,
    required this.child,
    this.gradientColors,
    this.useSurfaceBackground = false,
    this.flat = false,
  });

  final bool flat;
  final Color accent;
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final int selectedCount;
  final String Function(int count) countLabel;
  final Widget child;
  final List<Color>? gradientColors;
  final bool useSurfaceBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (flat) {
      return child;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: gradientColors != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors!,
              )
            : null,
        color: useSurfaceBackground
            ? theme.colorScheme.surface.withValues(alpha: isDark ? 0.6 : 0.95)
            : null,
        border: Border.all(
          color: useSurfaceBackground
              ? theme.colorScheme.outline.withValues(
                  alpha: isDark ? 0.14 : 0.09,
                )
              : accent.withValues(alpha: isDark ? 0.18 : 0.14),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: accent.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isDark ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontFamily: AppFonts.display,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                          if (selectedCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(
                                  alpha: isDark ? 0.2 : 0.12,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                countLabel(selectedCount),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontFamily: AppFonts.body,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: AppFonts.body,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}

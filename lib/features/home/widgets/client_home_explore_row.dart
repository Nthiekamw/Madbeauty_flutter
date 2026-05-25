import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../theme/home_styles.dart';
import 'client_home_section_header.dart';

/// Grille de catégories visuelles vers la recherche / listing.
class ClientHomeExploreRow extends StatelessWidget {
  const ClientHomeExploreRow({
    super.key,
    required this.onPick,
  });

  final ValueChanged<String> onPick;

  static const List<({String label, IconData icon, Color color})> _topics = [
    (
      label: 'Tresses',
      icon: Icons.waves_rounded,
      color: Color(0xFF7C3AED),
    ),
    (
      label: 'Locks',
      icon: Icons.all_inclusive_rounded,
      color: Color(0xFF0EA5E9),
    ),
    (
      label: 'Coiffure afro',
      icon: Icons.face_retouching_natural_outlined,
      color: Color(0xFFEC4899),
    ),
    (
      label: 'Coupe',
      icon: Icons.content_cut_rounded,
      color: Color(0xFF10B981),
    ),
    (
      label: 'Entretien',
      icon: Icons.spa_outlined,
      color: Color(0xFFF59E0B),
    ),
    (
      label: 'Coloration',
      icon: Icons.palette_outlined,
      color: Color(0xFFEF4444),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ClientHomeSectionHeader(
          title: DiscHome.inspireTitle,
          subtitle: DiscHome.inspireSub,
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            // 3 colonnes avec espacement, hauteur calculée proportionnellement
            const spacing = 10.0;
            final tileW = (constraints.maxWidth - spacing * 2) / 3;
            final tileH = tileW * 0.9;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: _topics.map((topic) {
                return SizedBox(
                  width: tileW,
                  height: tileH,
                  child: _ExploreTile(
                    label: topic.label,
                    icon: topic.icon,
                    accentColor: topic.color,
                    onTap: () => onPick(topic.label),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: HomeStyles.cardBorderRadius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: HomeStyles.cardBorderRadius,
            color: theme.colorScheme.surface.withValues(
              alpha: isDark ? 0.85 : 0.95,
            ),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: isDark ? 0.08 : 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(icon, size: 22, color: accentColor),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

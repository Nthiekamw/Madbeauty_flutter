import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../theme/home_styles.dart';
import 'client_home_section_header.dart';

/// Puces « inspiration » vers la recherche / listing.
class ClientHomeExploreRow extends StatelessWidget {
  const ClientHomeExploreRow({
    super.key,
    required this.onPick,
  });

  final ValueChanged<String> onPick;

  static const List<({String label, IconData icon})> _topics = [
    (label: 'Tresses', icon: Icons.waves_rounded),
    (label: 'Locks', icon: Icons.all_inclusive_rounded),
    (label: 'Coiffure afro', icon: Icons.face_retouching_natural_outlined),
    (label: 'Coupe', icon: Icons.content_cut_rounded),
    (label: 'Entretien', icon: Icons.spa_outlined),
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
        SizedBox(
          height: MediaQuery.sizeOf(context).width / 100 * 9.5,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _topics.length,
            itemBuilder: (context, index) {
              final topic = _topics[index];
              return _ExploreChip(
                label: topic.label,
                icon: topic.icon,
                onTap: () => onPick(topic.label),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ExploreChip extends StatelessWidget {
  const _ExploreChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isDark) {
      final primary = theme.colorScheme.primary;
      return Material(
        color: theme.colorScheme.surface.withValues(alpha: 0.85),
        shape: RoundedRectangleBorder(
          borderRadius: HomeStyles.chipBorderRadius,
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: HomeStyles.chipBorderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: primary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _PrototypeExploreChip(label: label, icon: icon, onTap: onTap);
  }
}

class _PrototypeExploreChip extends StatelessWidget {
  const _PrototypeExploreChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rem = MediaQuery.sizeOf(context).width / 100;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: rem * 2),
        padding: EdgeInsets.symmetric(horizontal: rem * 3.5, vertical: rem * 1.8),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE0CC),
          borderRadius: BorderRadius.circular(rem * 6),
          border: Border.all(
            color: const Color(0xFFEDE0CC).withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: rem * 3.8, color: const Color(0xFF8B6340)),
            SizedBox(width: rem * 1.5),
            Text(
              label,
              style: TextStyle(
                fontSize: rem * 3,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8B6340),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _topics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
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
    final primary = theme.colorScheme.primary;

    return Material(
      color: theme.colorScheme.surface.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.85 : 0.95,
      ),
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
}

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/theme/discovery_styles.dart';
import 'prestataire_detail_section.dart';

/// Navigation rapide entre sections (épinglée au scroll).
class PrestataireDetailSectionNav extends StatelessWidget {
  const PrestataireDetailSectionNav({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final PrestataireDetailSection selected;
  final ValueChanged<PrestataireDetailSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 1,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.08),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _NavChip(
              label: DiscPrestaDetail.navServices,
              icon: Icons.content_cut_rounded,
              selected: selected == PrestataireDetailSection.services,
              onTap: () => onSelected(PrestataireDetailSection.services),
            ),
            const SizedBox(width: 8),
            _NavChip(
              label: DiscPrestaDetail.navGallery,
              icon: Icons.photo_library_outlined,
              selected: selected == PrestataireDetailSection.gallery,
              onTap: () => onSelected(PrestataireDetailSection.gallery),
            ),
            const SizedBox(width: 8),
            _NavChip(
              label: DiscPrestaDetail.navAbout,
              icon: Icons.info_outline_rounded,
              selected: selected == PrestataireDetailSection.about,
              onTap: () => onSelected(PrestataireDetailSection.about),
            ),
            const SizedBox(width: 8),
            _NavChip(
              label: DiscPrestaDetail.navReviews,
              icon: Icons.star_outline_rounded,
              selected: selected == PrestataireDetailSection.reviews,
              onTap: () => onSelected(PrestataireDetailSection.reviews),
            ),
          ],
        ),
      ),
    );
  }
}

class PrestataireDetailSectionNavDelegate extends SliverPersistentHeaderDelegate {
  PrestataireDetailSectionNavDelegate({
    required this.selected,
    required this.onSelected,
  });

  final PrestataireDetailSection selected;
  final ValueChanged<PrestataireDetailSection> onSelected;

  static const double height = 52;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return PrestataireDetailSectionNav(
      selected: selected,
      onSelected: onSelected,
    );
  }

  @override
  bool shouldRebuild(covariant PrestataireDetailSectionNavDelegate oldDelegate) {
    return oldDelegate.selected != selected;
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: selected
          ? primary.withValues(alpha: 0.12)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
      borderRadius: DiscoveryStyles.chipBorderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: DiscoveryStyles.chipBorderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? primary : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? primary : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

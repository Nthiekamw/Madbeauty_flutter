import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import 'prestataire_detail_section.dart';

/// Navigation rapide entre sections — puces style accueil.
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
    final pad = DiscoveryResponsive.of(context).horizontalPadding;
    final maxWidth = DiscoveryResponsive.of(context).contentMaxWidth;

    return ColoredBox(
      color: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(pad, 10, pad, 10),
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

  static const double height = 50;

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
    final theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.94),
      elevation: overlapsContent ? 0.5 : 0,
      shadowColor: AppColors.brandBrown.withValues(alpha: 0.06),
      child: PrestataireDetailSectionNav(
        selected: selected,
        onSelected: onSelected,
      ),
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
    final isDark = theme.brightness == Brightness.dark;
    final fill = selected
        ? theme.colorScheme.primary
        : (isDark
            ? AppColors.darkSurfaceContainerHigh
            : AppColors.filterChipInactive);
    final fg = selected
        ? theme.colorScheme.onPrimary
        : (isDark ? AppColors.darkOnSurface : AppColors.filterChipInactiveText);

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

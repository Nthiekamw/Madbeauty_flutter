import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import 'prestataire_detail_section.dart';

/// Navigation exclusive entre sections — puces style accueil (adaptée web).
class PrestataireDetailSectionNav extends StatelessWidget {
  const PrestataireDetailSectionNav({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final PrestataireDetailSection selected;
  final ValueChanged<PrestataireDetailSection> onSelected;

  static List<_NavChipSpec> get _specs => const [
        _NavChipSpec(
          section: PrestataireDetailSection.services,
          label: DiscPrestaDetail.navServices,
          icon: Icons.content_cut_rounded,
        ),
        _NavChipSpec(
          section: PrestataireDetailSection.boutique,
          label: DiscBoutique.navBoutique,
          icon: Icons.storefront_outlined,
        ),
        _NavChipSpec(
          section: PrestataireDetailSection.offres,
          label: DiscBoutique.navOffres,
          icon: Icons.local_offer_outlined,
        ),
        _NavChipSpec(
          section: PrestataireDetailSection.gallery,
          label: DiscPrestaDetail.navGallery,
          icon: Icons.photo_library_outlined,
        ),
        _NavChipSpec(
          section: PrestataireDetailSection.about,
          label: DiscPrestaDetail.navAbout,
          icon: Icons.info_outline_rounded,
        ),
        _NavChipSpec(
          section: PrestataireDetailSection.reviews,
          label: DiscPrestaDetail.navReviews,
          icon: Icons.star_outline_rounded,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    final pad = layout.pageHorizontalPadding(flow: true);
    final maxWidth = layout.useWebSiteLayout
        ? layout.webFlowContentMaxWidth
        : layout.contentMaxWidth;
    final chips = [
      for (final spec in _specs)
        _NavChip(
          label: spec.label,
          icon: spec.icon,
          selected: selected == spec.section,
          onTap: () => onSelected(spec.section),
          compact: !layout.useWebSiteLayout,
        ),
    ];

    return ColoredBox(
      color: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: layout.useWebSiteLayout && layout.isWide
              ? Padding(
                  padding: EdgeInsets.fromLTRB(pad, 10, pad, 10),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: chips,
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.fromLTRB(pad, 10, pad, 10),
                  child: Row(
                    children: [
                      for (var i = 0; i < chips.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        chips[i],
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _NavChipSpec {
  const _NavChipSpec({
    required this.section,
    required this.label,
    required this.icon,
  });

  final PrestataireDetailSection section;
  final String label;
  final IconData icon;
}

class PrestataireDetailSectionNavDelegate
    extends SliverPersistentHeaderDelegate {
  PrestataireDetailSectionNavDelegate({
    required this.selected,
    required this.onSelected,
    required this.height,
  });

  final PrestataireDetailSection selected;
  final ValueChanged<PrestataireDetailSection> onSelected;
  final double height;

  /// Hauteur sticky selon breakpoint (wrap web large = 2 lignes).
  static double heightFor(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    if (layout.useWebSiteLayout && layout.isWide) return 96;
    if (layout.useWebSiteLayout) return 56;
    return 50;
  }

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
    return oldDelegate.selected != selected || oldDelegate.height != height;
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.compact = true,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

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
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: compact ? 32 : 40),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 14,
              vertical: compact ? 7 : 9,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: compact ? 14 : 16, color: fg),
                SizedBox(width: compact ? 6 : 8),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 11 : 12.5,
                    color: fg,
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

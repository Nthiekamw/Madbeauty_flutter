import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../models/prestataire_dashboard_section_id.dart';
import '../shared/prestataire_section_header.dart';
import 'prestataire_dashboard_insets.dart';

class PrestataireDashboardLayoutTile extends StatelessWidget {
  const PrestataireDashboardLayoutTile({
    super.key,
    required this.sectionId,
    required this.collapsed,
    required this.onToggleCollapsed,
    required this.child,
    this.badgeCount,
    this.subtitle,
  });

  final PrestataireDashboardSectionId sectionId;
  final bool collapsed;
  final VoidCallback onToggleCollapsed;
  final Widget child;
  final int? badgeCount;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = metaFor(sectionId, theme);
    final accent = meta.$3 ?? theme.colorScheme.primary;

    final header = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggleCollapsed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: PrestataireSectionHeader(
                  icon: meta.$1,
                  title: meta.$2,
                  subtitle: collapsed ? null : subtitle,
                  badgeCount: badgeCount,
                  iconColor: accent,
                ),
              ),
              Tooltip(
                message: collapsed
                    ? DiscPrestaDash.layoutExpand
                    : DiscPrestaDash.layoutCollapse,
                child: AnimatedRotation(
                  turns: collapsed ? 0.0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    const innerHorizontal = 16.0;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: innerHorizontal),
          child: header,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          child: collapsed
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.fromLTRB(
                    innerHorizontal,
                    14,
                    innerHorizontal,
                    4,
                  ),
                  child: child,
                ),
        ),
      ],
    );

    return Padding(
      padding: PrestataireDashboardInsets.section(context),
      child: DiscoverySurfaceCard(
        includeHorizontalMargin: false,
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 14),
        child: body,
      ),
    );
  }

  static (IconData, String, Color?) metaFor(
    PrestataireDashboardSectionId id,
    ThemeData theme,
  ) {
    return switch (id) {
      PrestataireDashboardSectionId.hero => (
          Icons.storefront_rounded,
          DiscPrestaDash.sectionHero,
          theme.colorScheme.primary,
        ),
      PrestataireDashboardSectionId.analytics => (
          Icons.insights_rounded,
          DiscPrestaAnalytics.sectionTitle,
          theme.colorScheme.primary,
        ),
      PrestataireDashboardSectionId.stats => (
          Icons.speed_rounded,
          DiscPrestaDash.sectionStats,
          theme.colorScheme.secondary,
        ),
      PrestataireDashboardSectionId.pending => (
          Icons.inbox_rounded,
          DiscPrestaDash.pendingTitle,
          theme.colorScheme.tertiary,
        ),
      PrestataireDashboardSectionId.today => (
          Icons.today_rounded,
          DiscPrestaDash.todayTitle,
          theme.colorScheme.primary,
        ),
      PrestataireDashboardSectionId.week => (
          Icons.date_range_rounded,
          DiscPrestaDash.weekTitle,
          theme.colorScheme.secondary,
        ),
    };
  }
}

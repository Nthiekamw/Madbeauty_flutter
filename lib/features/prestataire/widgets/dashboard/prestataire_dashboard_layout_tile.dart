import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../models/prestataire_dashboard_section_id.dart';
import '../shared/prestataire_section_header.dart';

class PrestataireDashboardLayoutTile extends StatelessWidget {
  const PrestataireDashboardLayoutTile({
    super.key,
    required this.sectionId,
    required this.index,
    required this.collapsed,
    required this.onToggleCollapsed,
    required this.child,
    this.badgeCount,
    this.subtitle,
    this.wrapInCard = true,
  });

  final PrestataireDashboardSectionId sectionId;
  final int index;
  final bool collapsed;
  final VoidCallback onToggleCollapsed;
  final Widget child;
  final int? badgeCount;
  final String? subtitle;
  final bool wrapInCard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = _metaFor(sectionId, theme);

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ReorderableDragStartListener(
          index: index,
          child: Tooltip(
            message: DiscPrestaDash.layoutDragHint,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.85,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.35),
                ),
              ),
              child: Icon(
                Icons.drag_indicator_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
          ),
        ),
        Expanded(
          child: PrestataireSectionHeader(
            icon: meta.$1,
            title: meta.$2,
            subtitle: collapsed ? null : subtitle,
            badgeCount: badgeCount,
            iconColor: meta.$3,
          ),
        ),
        IconButton(
          tooltip: collapsed
              ? DiscPrestaDash.layoutExpand
              : DiscPrestaDash.layoutCollapse,
          onPressed: onToggleCollapsed,
          icon: Icon(
            collapsed
                ? Icons.expand_more_rounded
                : Icons.expand_less_rounded,
          ),
        ),
      ],
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        if (!collapsed) ...[
          const SizedBox(height: 12),
          child,
        ],
      ],
    );

    if (!wrapInCard) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: body,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: DiscoverySurfaceCard(
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
        child: body,
      ),
    );
  }

  static (IconData, String, Color?) _metaFor(
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
          Icons.dashboard_customize_outlined,
          DiscPrestaDash.sectionStats,
          theme.colorScheme.primary,
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

/// Bandeau d’aide sous l’en-tête dashboard.
class PrestataireDashboardLayoutHint extends StatelessWidget {
  const PrestataireDashboardLayoutHint({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: primary.withValues(alpha: 0.28)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.tune_rounded, color: primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DiscPrestaDash.layoutCustomizeTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DiscPrestaDash.layoutCustomizeHint,
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
      ),
    );
  }
}

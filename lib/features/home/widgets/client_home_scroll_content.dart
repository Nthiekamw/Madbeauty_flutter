import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../client/widgets/workspace/client_workspace_header.dart';
import '../../client/widgets/workspace/client_workspace_search_row.dart';
import 'client_home_explore_row.dart';
import 'client_home_feed_prestataires_section.dart';
import 'client_home_nearby_prestataires_section.dart';
import 'client_home_top_rated_prestataires_section.dart';
import '../theme/home_styles.dart';

/// Contenu scrollable partagé (connecté + invité).
class ClientHomeScrollContent extends ConsumerWidget {
  const ClientHomeScrollContent({
    super.key,
    required this.searchController,
    required this.onSubmitSearch,
    required this.onExplorePick,
    this.footer,
    this.showCatalogCta = true,
  });

  final TextEditingController searchController;
  final VoidCallback onSubmitSearch;
  final ValueChanged<String> onExplorePick;
  final Widget? footer;
  final bool showCatalogCta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final pad = DiscoveryResponsive.of(context).horizontalPadding;

    return ListView(
      padding: EdgeInsets.fromLTRB(pad, 0, pad, 32),
      children: [
        ClientWorkspaceSearchRow(
          controller: searchController,
          onChanged: (_) => onSubmitSearch(),
          onSubmitted: (_) => onSubmitSearch(),
          onFilterTap: () => context.goClientSearch(),
        ),
        if (showCatalogCta) ...[
          const SizedBox(height: 8),
          _CatalogCta(onTap: () => context.goClientSearch()),
        ],
        const SizedBox(height: 28),
        ClientHomeExploreRow(onPick: onExplorePick),
        if (AppConfig.hasSupabase) ...[
          const SizedBox(height: 32),
          const ClientHomeFeedPrestatairesSection(),
          const SizedBox(height: 32),
          const ClientHomeNearbyPrestatairesSection(),
          const SizedBox(height: 32),
          const ClientHomeTopRatedPrestatairesSection(),
        ],
        if (!AppConfig.hasSupabase) ...[
          const SizedBox(height: 28),
          _SupabaseConfigCard(theme: theme),
        ],
        if (footer != null) ...[
          const SizedBox(height: 20),
          footer!,
        ],
      ],
    );
  }
}

class _CatalogCta extends StatelessWidget {
  const _CatalogCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      borderRadius: HomeStyles.chipBorderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: HomeStyles.chipBorderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.explore_outlined,
                color: theme.colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  DiscHome.ctaBrowseCatalog,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupabaseConfigCard extends StatelessWidget {
  const _SupabaseConfigCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: HomeStyles.cardBorderRadius,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ShellStrings.supabaseMissingTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ShellStrings.supabaseMissingBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pied de page optionnel : indicateur cache profil.
Widget? clientHomeProfileCacheFooter(ThemeData theme, bool fromCache) {
  if (!fromCache) return null;
  return Text(
    ShellStrings.profileSourceCache,
    textAlign: TextAlign.center,
    style: theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.outline,
    ),
  );
}

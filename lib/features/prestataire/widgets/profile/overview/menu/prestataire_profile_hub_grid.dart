import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../router/navigation_extensions.dart';
import '../../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../../shared/theme/app_colors.dart';
import '../../../../../../shared/theme/app_fonts.dart';
import '../../../../../../shared/theme/app_icons.dart';
import '../../../../../../shared/widgets/discovery/discovery_menu_tile.dart';
import '../../../../../../shared/widgets/discovery/discovery_surface_card.dart';

/// Raccourcis cockpit : liste sur mobile, grille sur web.
class PrestataireProfileHubGrid extends StatelessWidget {
  const PrestataireProfileHubGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tiles = <_HubTileData>[
      _HubTileData(
        icon: AppIcons.storefront,
        title: DiscPrestaProfile.hubSalonTitle,
        hint: DiscPrestaProfile.hubSalonHint,
        onTap: () => context.pushPrestataireProfileSalon(),
      ),
      _HubTileData(
        icon: AppIcons.boutique,
        title: DiscPrestaProfile.hubBoutiqueTitle,
        hint: DiscPrestaProfile.hubBoutiqueHint,
        onTap: () => context.pushPrestataireProfileBoutique(),
      ),
      _HubTileData(
        icon: AppIcons.reels,
        title: DiscPrestaProfile.hubReelsTitle,
        hint: DiscPrestaProfile.hubReelsHint,
        onTap: () => context.pushPrestataireReel(),
      ),
      _HubTileData(
        icon: AppIcons.reviews,
        title: DiscPrestaProfile.hubAvisTitle,
        hint: DiscPrestaProfile.hubAvisHint,
        onTap: () => context.pushPrestataireReceivedReviews(),
      ),
      _HubTileData(
        icon: AppIcons.account,
        title: DiscPrestaProfile.hubCompteTitle,
        hint: DiscPrestaProfile.hubCompteHint,
        onTap: () => context.pushPrestataireProfileAccount(),
      ),
    ];

    final layout = DiscoveryResponsive.of(context);
    if (layout.useWebTwoPane) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final cols = constraints.maxWidth >= 720 ? 3 : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tiles.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.28,
            ),
            itemBuilder: (context, i) => _HubCard(data: tiles[i]),
          );
        },
      );
    }

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
              ),
            DiscoveryMenuTile(
              icon: tiles[i].icon,
              title: tiles[i].title,
              subtitle: tiles[i].hint,
              onTap: tiles[i].onTap,
            ),
          ],
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({required this.data});

  final _HubTileData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return DiscoverySurfaceCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: data.onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(data.icon, size: 22, color: primary),
                const Spacer(),
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.hint,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
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

class _HubTileData {
  const _HubTileData({
    required this.icon,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String hint;
  final VoidCallback onTap;
}

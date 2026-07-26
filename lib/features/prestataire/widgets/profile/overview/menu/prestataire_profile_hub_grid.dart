import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../router/navigation_extensions.dart';
import '../../../../../../shared/widgets/discovery/discovery_menu_tile.dart';
import '../../../../../../shared/widgets/discovery/discovery_surface_card.dart';

/// Raccourcis cockpit : liste verticale, boutons pleine largeur.
class PrestataireProfileHubGrid extends StatelessWidget {
  const PrestataireProfileHubGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tiles = <_HubTileData>[
      _HubTileData(
        icon: Icons.storefront_rounded,
        title: DiscPrestaProfile.hubSalonTitle,
        hint: DiscPrestaProfile.hubSalonHint,
        onTap: () => context.pushPrestataireProfileSalon(),
      ),
      _HubTileData(
        icon: Icons.shopping_bag_outlined,
        title: DiscPrestaProfile.hubBoutiqueTitle,
        hint: DiscPrestaProfile.hubBoutiqueHint,
        onTap: () => context.pushPrestataireProfileBoutique(),
      ),
      _HubTileData(
        icon: Icons.movie_filter_outlined,
        title: DiscPrestaProfile.hubReelsTitle,
        hint: DiscPrestaProfile.hubReelsHint,
        onTap: () => context.pushPrestataireReel(),
      ),
      _HubTileData(
        icon: Icons.rate_review_outlined,
        title: DiscPrestaProfile.hubAvisTitle,
        hint: DiscPrestaProfile.hubAvisHint,
        onTap: () => context.pushPrestataireReceivedReviews(),
      ),
      _HubTileData(
        icon: Icons.manage_accounts_outlined,
        title: DiscPrestaProfile.hubCompteTitle,
        hint: DiscPrestaProfile.hubCompteHint,
        onTap: () => context.pushPrestataireProfileAccount(),
      ),
    ];

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

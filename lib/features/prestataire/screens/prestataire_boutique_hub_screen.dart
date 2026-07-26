import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/widgets/discovery/discovery_menu_tile.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../widgets/profile/overview/layout/prestataire_profile_insets.dart';
import '../widgets/shared/prestataire_section_header.dart';

/// Hub Boutique : produits, packs, commandes.
class PrestataireBoutiqueHubScreen extends StatelessWidget {
  const PrestataireBoutiqueHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = PrestataireProfileInsets.page(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(DiscPrestaProfile.hubBoutiqueScreenTitle),
      ),
      body: ListView(
        padding: padding.copyWith(bottom: 32),
        children: [
          PrestataireSectionHeader(
            icon: Icons.shopping_bag_outlined,
            title: DiscPrestaProfile.hubBoutiqueScreenTitle,
            subtitle: DiscPrestaProfile.hubBoutiqueScreenSubtitle,
            iconColor: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          DiscoverySurfaceCard(
            child: Column(
              children: [
                DiscoveryMenuTile(
                  icon: Icons.storefront_outlined,
                  title: DiscBoutique.menuBoutique,
                  subtitle: DiscBoutique.menuBoutiqueHint,
                  onTap: () => context.pushPrestataireBoutique(),
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outline.withValues(alpha: 0.12),
                ),
                DiscoveryMenuTile(
                  icon: Icons.local_offer_outlined,
                  title: DiscBoutique.menuPacks,
                  subtitle: DiscBoutique.menuPacksHint,
                  onTap: () => context.pushPrestatairePacks(),
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outline.withValues(alpha: 0.12),
                ),
                DiscoveryMenuTile(
                  icon: Icons.receipt_long_outlined,
                  title: DiscBoutique.menuOrders,
                  subtitle: DiscBoutique.menuOrdersHint,
                  onTap: () => context.pushPrestataireBoutiqueOrders(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

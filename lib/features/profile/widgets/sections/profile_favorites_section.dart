import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/widgets/discovery/discovery_menu_tile.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../cart/providers/boutique_cart_provider.dart';
import '../../../favorites/providers/client_favorite_prestataire_ids_provider.dart';
import '../layout/profile_section_title.dart';

/// Accès rapide « Mes favoris » depuis le profil client.
class ProfileFavoritesSection extends ConsumerWidget {
  const ProfileFavoritesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final count = ref.watch(clientFavoritesCountProvider);
    final subtitle = count == 0
        ? DiscFavori.profileEmptyHint
        : DiscFavori.profileCountHint(count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProfileSectionTitle(
          title: DiscFavori.profileSectionTitle,
          icon: Icons.bookmark_rounded,
        ),
        DiscoverySurfaceCard(
          child: Column(
            children: [
              DiscoveryMenuTile(
                icon: Icons.event_outlined,
                title: DiscReel.profileReservationsTitle,
                subtitle: DiscReel.profileReservationsHint,
                onTap: () => context.pushMyReservations(),
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
              ),
              DiscoveryMenuTile(
                icon: Icons.bookmark_rounded,
                title: DiscProfile.actionFavorites,
                subtitle: subtitle,
                iconColor: theme.colorScheme.error,
                onTap: () => context.pushClientFavorites(),
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final cartCount = ref.watch(boutiqueCartItemCountProvider);
                  return DiscoveryMenuTile(
                    icon: Icons.shopping_bag_outlined,
                    title: DiscBoutique.menuCart,
                    subtitle: cartCount > 0
                        ? DiscBoutique.produitsCount(cartCount)
                        : DiscBoutique.menuCartHint,
                    onTap: () => context.pushClientCart(),
                  );
                },
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
              ),
              DiscoveryMenuTile(
                icon: Icons.receipt_long_outlined,
                title: DiscBoutique.menuClientOrders,
                subtitle: DiscBoutique.menuClientOrdersHint,
                onTap: () => context.pushClientBoutiqueOrders(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


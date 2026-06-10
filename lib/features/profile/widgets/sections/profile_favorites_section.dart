import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/widgets/discovery/discovery_menu_tile.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
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
        const ProfileSectionTitle(title: DiscFavori.profileSectionTitle),
        DiscoverySurfaceCard(
          child: DiscoveryMenuTile(
            icon: Icons.bookmark_rounded,
            title: DiscProfile.actionFavorites,
            subtitle: subtitle,
            iconColor: theme.colorScheme.error,
            onTap: () => context.pushClientFavorites(),
          ),
        ),
      ],
    );
  }
}


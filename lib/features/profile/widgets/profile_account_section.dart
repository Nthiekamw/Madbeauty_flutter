import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/discovery_menu_tile.dart';
import '../../../shared/widgets/discovery_surface_card.dart';
import 'profile_section_title.dart';

class ProfileAccountSection extends StatelessWidget {
  const ProfileAccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProfileSectionTitle(title: DiscProfile.sectionAccount),
        DiscoverySurfaceCard(
          child: Column(
            children: [
              DiscoveryMenuTile(
                icon: Icons.person_outline_rounded,
                title: DiscProfile.actionEditAccount,
                onTap: () => context.pushEditClientAccount(),
              ),
              _divider(context),
              DiscoveryMenuTile(
                icon: Icons.favorite_border_rounded,
                title: DiscProfile.actionFavorites,
                onTap: () => _comingSoon(context),
              ),
              _divider(context),
              DiscoveryMenuTile(
                icon: Icons.rate_review_outlined,
                title: DiscProfile.actionReviews,
                onTap: () => _comingSoon(context),
              ),
              _divider(context),
              DiscoveryMenuTile(
                icon: Icons.history_rounded,
                title: DiscProfile.actionHistory,
                onTap: () => context.goMyReservations(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
    );
  }

  void _comingSoon(BuildContext context) {
    AppSnackBar.show(context, message: DiscProfile.comingSoon);
  }
}

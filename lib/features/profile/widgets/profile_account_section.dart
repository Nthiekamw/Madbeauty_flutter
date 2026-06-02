import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/widgets/discovery/discovery_menu_tile.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../auth/guest/guest_mode_provider.dart';
import 'profile_section_title.dart';

class ProfileAccountSection extends ConsumerWidget {
  const ProfileAccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestBrowsingProvider);
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
                icon: Icons.rate_review_outlined,
                title: DiscProfile.actionReviews,
                onTap: () => context.pushClientReviews(),
              ),
              _divider(context),
              DiscoveryMenuTile(
                icon: Icons.history_rounded,
                title: DiscProfile.actionHistory,
                onTap: () => context.pushClientHistory(),
              ),
              _divider(context),
              DiscoveryMenuTile(
                icon: Icons.card_giftcard_rounded,
                title: DiscProfile.actionReferral,
                subtitle: DiscProfile.actionReferralHint,
                onTap: isGuest ? null : () => context.pushClientReferral(),
              ),
              _divider(context),
              DiscoveryMenuTile(
                icon: Icons.help_outline_rounded,
                title: DiscProfile.actionHelp,
                onTap: () => context.pushClientHelp(),
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

}

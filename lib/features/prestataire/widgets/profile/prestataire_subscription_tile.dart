import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../services/stripe/stripe_subscription_providers.dart';
import '../../../../shared/widgets/discovery/discovery_menu_tile.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';

class PrestataireSubscriptionTile extends ConsumerWidget {
  const PrestataireSubscriptionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(prestataireSubscriptionStatusProvider);
    final subtitle = statusAsync.when(
      data: (s) => s.isActive
          ? DiscPrestaSub.statusActive
          : DiscPrestaSub.profileTileSubtitle,
      loading: () => DiscPrestaSub.profileTileSubtitle,
      error: (_, __) => DiscPrestaSub.profileTileSubtitle,
    );

    return DiscoverySurfaceCard(
      child: DiscoveryMenuTile(
        icon: Icons.card_membership_rounded,
        title: DiscPrestaSub.profileTileTitle,
        subtitle: subtitle,
        onTap: () => context.pushPrestataireSubscription(),
      ),
    );
  }
}

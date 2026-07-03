import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../router/navigation_extensions.dart';
import '../../../../../../services/supabase/prestataire/subscription/prestataire_subscription_providers.dart';
import '../../../../../../../shared/widgets/discovery/discovery_menu_tile.dart';

/// Entrée « Accès catalogue » dans Mon compte prestataire.
class PrestataireProfileAccountMenu extends ConsumerWidget {
  const PrestataireProfileAccountMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(prestataireSubscriptionStatusProvider);

    final subscriptionSubtitle = subscriptionAsync.when(
      data: (status) => status.hasCatalogAccess
          ? DiscPrestaSub.statusActive
          : DiscPrestaSub.accountPlansHint,
      loading: () => DiscPrestaSub.accountPlansHint,
      error: (_, __) => DiscPrestaSub.accountPlansHint,
    );

    return DiscoveryMenuTile(
      icon: Icons.workspace_premium_rounded,
      title: DiscPrestaSub.accountPlansTitle,
      subtitle: subscriptionSubtitle,
      onTap: () => context.pushPrestataireSubscription(),
    );
  }
}

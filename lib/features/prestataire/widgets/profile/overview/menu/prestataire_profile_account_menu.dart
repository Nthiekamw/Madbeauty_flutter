import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/config/stripe_platform_policy.dart';
import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../router/navigation_extensions.dart';
import '../../../../../../services/stripe/stripe_connect_providers.dart';
import '../../../../../../services/supabase/prestataire/subscription/prestataire_subscription_providers.dart';
import '../../../../../../../shared/widgets/discovery/discovery_menu_tile.dart';

/// Entrées « Accès catalogue » et « Moyens de paiement » dans Mon compte prestataire.
class PrestataireProfileAccountMenu extends ConsumerWidget {
  const PrestataireProfileAccountMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!StripePlatformPolicy.isEnabled) {
      return DiscoveryMenuTile(
        icon: Icons.workspace_premium_rounded,
        title: DiscPrestaSub.accountPlansTitle,
        subtitle: DiscPrestaSub.accountPlansHint,
        onTap: () => context.pushPrestataireSubscription(),
      );
    }

    final subscriptionAsync = ref.watch(prestataireSubscriptionStatusProvider);
    final connectAsync = ref.watch(prestataireStripeConnectProvider);

    final subscriptionSubtitle = subscriptionAsync.when(
      data: (status) => status.hasCatalogAccess
          ? DiscPrestaSub.statusActive
          : DiscPrestaSub.accountPlansHint,
      loading: () => DiscPrestaSub.accountPlansHint,
      error: (_, __) => DiscPrestaSub.accountPlansHint,
    );

    final paymentSubtitle = connectAsync.when(
      data: (connect) {
        if (connect?.canAcceptPayments == true) {
          return DiscPaymentMethods.payoutActive;
        }
        if (connect?.accountId != null) {
          return DiscPaymentMethods.payoutPending;
        }
        return DiscPaymentMethods.accountMenuHint;
      },
      loading: () => DiscPaymentMethods.accountMenuHint,
      error: (_, __) => DiscPaymentMethods.accountMenuHint,
    );

    return Column(
      children: [
        DiscoveryMenuTile(
          icon: Icons.workspace_premium_rounded,
          title: DiscPrestaSub.accountPlansTitle,
          subtitle: subscriptionSubtitle,
          onTap: () => context.pushPrestataireSubscription(),
        ),
        Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
        ),
        DiscoveryMenuTile(
          icon: Icons.payment_rounded,
          title: DiscPaymentMethods.sectionTitle,
          subtitle: paymentSubtitle,
          onTap: () => context.pushPrestatairePaymentMethods(),
        ),
      ],
    );
  }
}

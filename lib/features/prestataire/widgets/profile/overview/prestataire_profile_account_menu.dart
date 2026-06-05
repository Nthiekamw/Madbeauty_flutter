import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../../../services/stripe/stripe_connect_providers.dart';
import '../../../../../services/stripe/stripe_service.dart';
import '../../../../../services/stripe/stripe_subscription_providers.dart';
import '../../../../../shared/widgets/discovery/discovery_menu_tile.dart';

/// Entrées « Abonnements » et « Moyens de paiement » dans Mon compte.
class PrestataireProfileAccountMenu extends ConsumerWidget {
  const PrestataireProfileAccountMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!StripeService.isConfigured) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final subscriptionAsync = ref.watch(prestataireSubscriptionStatusProvider);
    final connectAsync = ref.watch(prestataireStripeConnectProvider);

    final subscriptionSubtitle = subscriptionAsync.when(
      data: (status) => status.isActive
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
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
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

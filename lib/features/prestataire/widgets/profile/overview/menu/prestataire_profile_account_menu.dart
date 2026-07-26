import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/config/stripe_platform_policy.dart';
import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../router/navigation_extensions.dart';
import '../../../../../../services/stripe/stripe_connect_providers.dart';
import '../../../../../../shared/widgets/discovery/discovery_menu_tile.dart';

/// Entrée « Moyens de paiement » dans Mon compte prestataire.
class PrestataireProfileAccountMenu extends ConsumerWidget {
  const PrestataireProfileAccountMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!StripePlatformPolicy.isEnabled) {
      return const SizedBox.shrink();
    }

    final connectAsync = ref.watch(prestataireStripeConnectProvider);
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

    return DiscoveryMenuTile(
      icon: Icons.payment_rounded,
      title: DiscPaymentMethods.sectionTitle,
      subtitle: paymentSubtitle,
      onTap: () => context.pushPrestatairePaymentMethods(),
    );
  }
}

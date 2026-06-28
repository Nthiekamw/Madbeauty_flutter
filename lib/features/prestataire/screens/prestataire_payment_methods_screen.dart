import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/widgets/discovery/discovery_screen_header.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../widgets/profile/overview/sections/prestataire_payment_methods_section.dart';
import '../widgets/profile/overview/layout/prestataire_profile_insets.dart';
import '../widgets/workspace/layout/prestataire_brand_scaffold.dart';
import '../widgets/workspace/prestataire_flow_scaffold.dart';

/// Écran dédié : abonnement (carte) + encaissement Stripe Connect.
class PrestatairePaymentMethodsScreen extends StatelessWidget {
  const PrestatairePaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;
    final listPadding = useWeb
        ? const EdgeInsets.fromLTRB(20, 16, 20, 32)
        : EdgeInsets.only(
            bottom: PrestataireProfileInsets.listBottom(context),
          );

    return PrestataireFlowScaffold(
      appBar: prestataireBrandAppBar(
        context: context,
        title: const Text(DiscPaymentMethods.sectionTitle),
      ),
      body: ListView(
        padding: listPadding,
        children: [
          if (!useWeb)
            const DiscoveryScreenHeader(
              title: DiscPaymentMethods.sectionTitle,
              subtitle: DiscPaymentMethods.sectionSubtitle,
            ),
          if (!useWeb)
            Padding(
              padding: PrestataireProfileInsets.page(context),
              child: const DiscoverySurfaceCard(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: PrestatairePaymentMethodsSection(standalone: true),
              ),
            )
          else
            const DiscoverySurfaceCard(
              includeHorizontalMargin: false,
              padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: PrestatairePaymentMethodsSection(standalone: true),
            ),
        ],
      ),
    );
  }
}

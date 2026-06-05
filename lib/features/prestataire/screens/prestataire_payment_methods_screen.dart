import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/discovery/discovery_screen_header.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../widgets/profile/overview/prestataire_payment_methods_section.dart';
import '../widgets/profile/overview/prestataire_profile_insets.dart';

/// Écran dédié : abonnement (carte) + encaissement Stripe Connect.
class PrestatairePaymentMethodsScreen extends StatelessWidget {
  const PrestatairePaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(DiscPaymentMethods.sectionTitle)),
      body: ListView(
        padding: EdgeInsets.only(
          bottom: PrestataireProfileInsets.listBottom(context),
        ),
        children: [
          const DiscoveryScreenHeader(
            title: DiscPaymentMethods.sectionTitle,
            subtitle: DiscPaymentMethods.sectionSubtitle,
          ),
          Padding(
            padding: PrestataireProfileInsets.page(context),
            child: const DiscoverySurfaceCard(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: PrestatairePaymentMethodsSection(standalone: true),
            ),
          ),
        ],
      ),
    );
  }
}

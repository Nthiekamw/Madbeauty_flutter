import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/discovery/discovery_screen_header.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../widgets/sections/client_payment_methods_section.dart';
import '../widgets/layout/profile_page_insets.dart';

/// Écran dédié : cartes bancaires client (portail Stripe).
class ClientPaymentMethodsScreen extends StatelessWidget {
  const ClientPaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(DiscPaymentMethods.sectionTitle)),
      body: ListView(
        padding: EdgeInsets.only(
          bottom: ProfilePageInsets.horizontal(context) + 16,
        ),
        children: [
          const DiscoveryScreenHeader(
            title: DiscPaymentMethods.sectionTitle,
            subtitle: DiscPaymentMethods.clientSectionSubtitle,
          ),
          Padding(
            padding: ProfilePageInsets.page(context),
            child: const DiscoverySurfaceCard(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: ClientPaymentMethodsSection(),
            ),
          ),
        ],
      ),
    );
  }
}

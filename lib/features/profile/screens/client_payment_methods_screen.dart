import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../services/stripe/client_payment_methods_provider.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/layout/web_flow_panel.dart';
import '../../../shared/layout/web_flow_scaffold.dart';
import '../../../shared/widgets/discovery/discovery_screen_header.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../widgets/layout/profile_page_insets.dart';
import '../widgets/sections/client_payment_methods_section.dart';

/// Écran dédié : cartes bancaires client (Customer Sheet Stripe).
class ClientPaymentMethodsScreen extends ConsumerWidget {
  const ClientPaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;

    return WebFlowScaffold(
      appBar: AppBar(title: const Text(DiscPaymentMethods.sectionTitle)),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(clientPaymentMethodsProvider.future),
        child: WebFlowPanel(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              useWeb ? 20 : ProfilePageInsets.horizontal(context),
              useWeb ? 16 : 0,
              useWeb ? 20 : ProfilePageInsets.horizontal(context),
              24,
            ),
            children: [
              if (!useWeb)
                const DiscoveryScreenHeader(
                  title: DiscPaymentMethods.sectionTitle,
                  subtitle: DiscPaymentMethods.clientSectionSubtitle,
                ),
              if (!useWeb)
                Padding(
                  padding: ProfilePageInsets.page(context),
                  child: const DiscoverySurfaceCard(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: ClientPaymentMethodsSection(),
                  ),
                )
              else
                const DiscoverySurfaceCard(
                  includeHorizontalMargin: false,
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: ClientPaymentMethodsSection(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

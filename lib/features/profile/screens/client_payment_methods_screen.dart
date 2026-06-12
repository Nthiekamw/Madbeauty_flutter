import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/domain.dart';
import '../../../services/stripe/client_payment_methods_provider.dart';
import '../../../shared/widgets/discovery/discovery_screen_header.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../widgets/layout/profile_page_insets.dart';
import '../widgets/sections/client_payment_methods_section.dart';

/// Écran dédié : cartes bancaires client (Customer Sheet Stripe).
class ClientPaymentMethodsScreen extends ConsumerWidget {
  const ClientPaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(DiscPaymentMethods.sectionTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            // Force le rechargement du type List<ClientPaymentMethod> (évite lookup stale).
            await ref.refresh(clientPaymentMethodsProvider.future);
          } catch (e, st) {
            if (kDebugMode) {
              debugPrint('refresh client payment methods: $e\n$st');
            }
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
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
      ),
    );
  }
}

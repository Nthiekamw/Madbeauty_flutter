import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/widgets/discovery/discovery_menu_tile.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../services/supabase/prestataire/subscription/prestataire_subscription_providers.dart';
import '../providers/profile/prestataire_profile_form_provider.dart';
import '../widgets/profile/overview/layout/prestataire_profile_insets.dart';
import '../widgets/profile/overview/menu/prestataire_profile_manage_menu.dart';
import '../widgets/shared/prestataire_section_header.dart';

/// Hub « Mon salon » : vitrine, horaires, abonnement, fiche publique.
class PrestataireSalonHubScreen extends ConsumerWidget {
  const PrestataireSalonHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(prestataireProfileFormProvider);
    final subscriptionAsync = ref.watch(prestataireSubscriptionStatusProvider);
    final padding = PrestataireProfileInsets.page(context);

    final subscriptionSubtitle = subscriptionAsync.when(
      data: (status) => status.hasCatalogAccess
          ? DiscPrestaSub.statusActive
          : DiscPrestaSub.accountPlansHint,
      loading: () => DiscPrestaSub.accountPlansHint,
      error: (_, __) => DiscPrestaSub.accountPlansHint,
    );

    return Scaffold(
      appBar: AppBar(title: const Text(DiscPrestaProfile.hubSalonScreenTitle)),
      body: ListView(
        padding: padding.copyWith(bottom: 32),
        children: [
          PrestataireSectionHeader(
            icon: Icons.storefront_rounded,
            title: DiscPrestaProfile.hubSalonScreenTitle,
            subtitle: DiscPrestaProfile.hubSalonScreenSubtitle,
            iconColor: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const PrestataireProfileManageMenu(showHeader: false),
          const SizedBox(height: 12),
          DiscoverySurfaceCard(
            child: Column(
              children: [
                DiscoveryMenuTile(
                  icon: Icons.schedule_rounded,
                  title: DiscPrestaProfile.horaires,
                  subtitle: DiscPrestaProfile.menuHorairesHint,
                  onTap: () => context.pushPrestataireHoraires(),
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outline.withValues(alpha: 0.12),
                ),
                DiscoveryMenuTile(
                  icon: Icons.workspace_premium_rounded,
                  title: DiscPrestaSub.profileTileTitle,
                  subtitle: subscriptionSubtitle,
                  onTap: () => context.pushPrestataireSubscription(),
                ),
                profileAsync.maybeWhen(
                  data: (data) {
                    final id = data.prestataireId;
                    if (id == null || id.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: theme.colorScheme.outline
                              .withValues(alpha: 0.12),
                        ),
                        DiscoveryMenuTile(
                          icon: Icons.visibility_rounded,
                          title: DiscPrestaProfile.publicFiche,
                          subtitle: DiscPrestaProfile.publicFicheHint,
                          onTap: () => context.pushPrestataireDetail(id),
                        ),
                      ],
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

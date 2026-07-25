import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/boutique_commande.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/guest/widgets/guest_account_prompt.dart';
import '../../auth/providers/auth_notifier.dart';
import '../providers/client_boutique_commandes_provider.dart';

/// Historique des commandes boutique du client.
class ClientBoutiqueOrdersScreen extends ConsumerWidget {
  const ClientBoutiqueOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = switch (ref.watch(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final isGuest = ref.watch(isGuestBrowsingProvider);
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;
    final listPadding = useWeb
        ? const EdgeInsets.fromLTRB(20, 16, 20, 28)
        : const EdgeInsets.fromLTRB(16, 12, 16, 24);

    if (user == null || isGuest) {
      return Scaffold(
        appBar: AppBar(title: const Text(DiscBoutique.clientOrdersTitle)),
        body: GuestAccountPrompt(
          icon: Icons.receipt_long_outlined,
          title: DiscBoutique.clientOrdersTitle,
          message: DiscBoutique.clientOrdersGuestBody,
        ),
      );
    }

    final async = ref.watch(clientBoutiqueCommandesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(DiscBoutique.clientOrdersTitle),
        actions: [
          IconButton(
            tooltip: DiscBoutique.menuCart,
            onPressed: () => context.pushClientCart(),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: useWeb ? 720 : double.infinity,
          ),
          child: async.when(
            loading: () =>
                const DiscoveryListSkeleton(rowCount: 4, rowHeight: 110),
            error: (_, __) => DiscoveryEmptyState(
              icon: Icons.cloud_off_outlined,
              title: DiscBoutique.clientOrdersLoadErr,
              body: CoreStrings.networkErrorBody,
              actionLabel: DiscList.retry,
              onAction: () => ref.invalidate(clientBoutiqueCommandesProvider),
            ),
            data: (commandes) {
              if (commandes.isEmpty) {
                return DiscoveryEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: DiscBoutique.clientOrdersEmptyTitle,
                  body: DiscBoutique.clientOrdersEmptyBody,
                  actionLabel: DiscHome.ctaBrowseCatalog,
                  onAction: () => context.goClientSearch(),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(clientBoutiqueCommandesProvider);
                  await ref.read(clientBoutiqueCommandesProvider.future);
                },
                child: ListView.separated(
                  padding: listPadding,
                  itemCount: commandes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _ClientOrderCard(commande: commandes[index]);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ClientOrderCard extends StatelessWidget {
  const _ClientOrderCard({required this.commande});

  final BoutiqueCommande commande;

  String _statutLabel(BoutiqueCommandeStatut s) => switch (s) {
        BoutiqueCommandeStatut.pendingPayment =>
          DiscBoutique.statutPendingPayment,
        BoutiqueCommandeStatut.payOnSite => DiscBoutique.statutPayOnSite,
        BoutiqueCommandeStatut.paid => DiscBoutique.statutPaid,
        BoutiqueCommandeStatut.preparing => DiscBoutique.statutPreparing,
        BoutiqueCommandeStatut.ready => DiscBoutique.statutReady,
        BoutiqueCommandeStatut.completed => DiscBoutique.statutCompleted,
        BoutiqueCommandeStatut.canceled => DiscBoutique.statutCanceled,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat.yMMMd('fr_FR').add_Hm().format(
          commande.createdAt.toLocal(),
        );
    final salon = commande.prestataireDisplayName?.trim().isNotEmpty == true
        ? commande.prestataireDisplayName!
        : DiscBoutique.clientOrdersUnknownSalon;

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.all(14),
      child: InkWell(
        onTap: () => context.pushPrestataireDetail(commande.prestataireId),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    salon,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statutLabel(commande.statut),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              dateLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            for (final item in commande.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '${item.quantite}× ${item.nomSnapshot}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormat.eur(commande.amountEuros, decimals: true),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/models/domain/catalog/boutique_commande.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/prestataire/boutique/boutique_providers.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/guest/widgets/guest_account_prompt.dart';
import '../../auth/providers/auth_notifier.dart';
import '../providers/client_boutique_commandes_provider.dart';
import '../widgets/create_boutique_review_sheet.dart';

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

class _ClientOrderCard extends ConsumerStatefulWidget {
  const _ClientOrderCard({required this.commande});

  final BoutiqueCommande commande;

  @override
  ConsumerState<_ClientOrderCard> createState() => _ClientOrderCardState();
}

class _ClientOrderCardState extends ConsumerState<_ClientOrderCard> {
  bool _busy = false;

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

  String get _productsLabel => widget.commande.items
      .map((i) => '${i.quantite}× ${i.nomSnapshot}')
      .join(' · ');

  Future<void> _confirmReceipt() async {
    final service = ref.read(boutiqueCommandeServiceProvider);
    if (service == null) return;
    setState(() => _busy = true);
    try {
      await service.confirmReceiptAsClient(widget.commande.id);
      ref.invalidate(clientBoutiqueCommandesProvider);
      if (!mounted) return;
      AppSnackBar.success(context, DiscBoutique.clientConfirmReceiptSuccess);
      await _openReview();
    } catch (e) {
      if (!mounted) return;
      final msg = e is AppFailure
          ? e.message
          : DiscBoutique.clientConfirmReceiptErr;
      AppSnackBar.error(context, msg);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openReview() async {
    final ok = await showCreateBoutiqueReviewSheet(
      context,
      commandeId: widget.commande.id,
      productsLabel: _productsLabel,
    );
    if (!mounted) return;
    ref.invalidate(clientBoutiqueCommandesProvider);
    if (ok == true) {
      showBoutiqueReviewSuccessSnack(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final commande = widget.commande;
    final dateLabel = DateFormat.yMMMd('fr_FR').add_Hm().format(
          commande.createdAt.toLocal(),
        );
    final salon = commande.prestataireDisplayName?.trim().isNotEmpty == true
        ? commande.prestataireDisplayName!
        : DiscBoutique.clientOrdersUnknownSalon;
    final canConfirm = commande.statut.canClientConfirmReceipt;
    final canReview = commande.statut == BoutiqueCommandeStatut.completed &&
        !commande.hasClientReview;

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.pushPrestataireDetail(commande.prestataireId),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    salon,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statutLabel(commande.statut),
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
          if (canConfirm) ...[
            const SizedBox(height: 8),
            Text(
              DiscBoutique.clientReadyHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (canConfirm || canReview || commande.hasClientReview) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (canConfirm)
                  FilledButton(
                    onPressed: _busy ? null : _confirmReceipt,
                    child: Text(
                      _busy ? '…' : DiscBoutique.clientConfirmReceipt,
                    ),
                  ),
                if (canReview)
                  OutlinedButton(
                    onPressed: _busy ? null : _openReview,
                    child: const Text(DiscBoutique.clientRateProducts),
                  ),
                if (commande.hasClientReview)
                  Text(
                    DiscBoutique.clientRateProductsDone,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

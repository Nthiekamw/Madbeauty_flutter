import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/admin/admin_boutique_order_summary.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../models/admin_boutique_order_filters.dart';
import '../providers/admin_boutique_provider.dart';
import '../widgets/admin_boutique_reason_dialog.dart';
import '../widgets/admin_screen_scaffold.dart';

/// Liste admin des commandes boutique (+ catalogue + avis).
class AdminBoutiqueOrdersScreen extends ConsumerStatefulWidget {
  const AdminBoutiqueOrdersScreen({super.key});

  @override
  ConsumerState<AdminBoutiqueOrdersScreen> createState() =>
      _AdminBoutiqueOrdersScreenState();
}

class _AdminBoutiqueOrdersScreenState
    extends ConsumerState<AdminBoutiqueOrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  AdminBoutiqueOrderFilters _filters = const AdminBoutiqueOrderFilters();
  final _searchCtrl = TextEditingController();
  final _catalogSearchCtrl = TextEditingController();
  final _avisSearchCtrl = TextEditingController();
  String _catalogSearch = '';
  String _avisSearch = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    _catalogSearchCtrl.dispose();
    _avisSearchCtrl.dispose();
    super.dispose();
  }

  void _applyFilters(AdminBoutiqueOrderFilters next) {
    setState(() => _filters = next);
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _filters.fromDate ?? DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (picked == null || !mounted) return;
    _applyFilters(_filters.copyWith(fromDate: picked));
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _filters.toDate ?? DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (picked == null || !mounted) return;
    _applyFilters(
      _filters.copyWith(
        toDate: DateTime(picked.year, picked.month, picked.day, 23, 59, 59),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScreenScaffold(
      title: DiscProfile.actionAdminBoutique,
      body: Column(
        children: [
          const AdminScreenIntroBanner(
            icon: Icons.storefront_outlined,
            title: DiscProfile.adminBoutiqueIntroTitle,
            body: DiscProfile.adminBoutiqueIntroBody,
          ),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabs: const [
              Tab(text: DiscProfile.adminBoutiqueTabOrders),
              Tab(text: DiscProfile.adminBoutiqueTabAvis),
              Tab(text: DiscProfile.adminBoutiqueTabCatalog),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _OrdersTab(
                  filters: _filters,
                  searchCtrl: _searchCtrl,
                  dayFormat: DateFormat('dd/MM/yyyy', 'fr_FR'),
                  dateFormat: DateFormat('dd/MM/yyyy HH:mm', 'fr_FR'),
                  onFilters: _applyFilters,
                  onPickFrom: _pickFromDate,
                  onPickTo: _pickToDate,
                ),
                _AvisTab(
                  searchCtrl: _avisSearchCtrl,
                  search: _avisSearch,
                  dateFormat: DateFormat('dd/MM/yyyy HH:mm', 'fr_FR'),
                  onSearch: (v) => setState(() => _avisSearch = v),
                ),
                _CatalogTab(
                  searchCtrl: _catalogSearchCtrl,
                  search: _catalogSearch,
                  onSearch: (v) => setState(() => _catalogSearch = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersTab extends ConsumerWidget {
  const _OrdersTab({
    required this.filters,
    required this.searchCtrl,
    required this.dayFormat,
    required this.dateFormat,
    required this.onFilters,
    required this.onPickFrom,
    required this.onPickTo,
  });

  final AdminBoutiqueOrderFilters filters;
  final TextEditingController searchCtrl;
  final DateFormat dayFormat;
  final DateFormat dateFormat;
  final ValueChanged<AdminBoutiqueOrderFilters> onFilters;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminBoutiqueOrdersProvider(filters));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              TextField(
                controller: searchCtrl,
                decoration: const InputDecoration(
                  labelText: DiscProfile.adminBoutiqueFilterSearch,
                  prefixIcon: Icon(Icons.search),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (v) => onFilters(
                  v.trim().isEmpty
                      ? filters.copyWith(clearSearch: true)
                      : filters.copyWith(search: v.trim()),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: filters.statut ?? '',
                decoration: const InputDecoration(
                  labelText: DiscProfile.adminBoutiqueFilterStatut,
                ),
                items: AdminBoutiqueOrderFilters.allStatuts
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          s.isEmpty
                              ? DiscProfile.adminReservationsFilterAll
                              : s,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => onFilters(
                  value == null || value.isEmpty
                      ? filters.copyWith(clearStatut: true)
                      : filters.copyWith(statut: value),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: filters.paymentStatus ?? '',
                decoration: const InputDecoration(
                  labelText: DiscProfile.adminBoutiqueFilterPayment,
                ),
                items: AdminBoutiqueOrderFilters.allPaymentStatuses
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          s.isEmpty
                              ? DiscProfile.adminReservationsFilterAll
                              : s,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => onFilters(
                  value == null || value.isEmpty
                      ? filters.copyWith(clearPaymentStatus: true)
                      : filters.copyWith(paymentStatus: value),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPickFrom,
                      icon: const Icon(Icons.date_range, size: 18),
                      label: Text(
                        filters.fromDate == null
                            ? DiscProfile.adminReservationsFilterFrom
                            : dayFormat.format(filters.fromDate!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPickTo,
                      icon: const Icon(Icons.date_range, size: 18),
                      label: Text(
                        filters.toDate == null
                            ? DiscProfile.adminReservationsFilterTo
                            : dayFormat.format(filters.toDate!),
                      ),
                    ),
                  ),
                ],
              ),
              if (filters.fromDate != null || filters.toDate != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => onFilters(
                      filters.copyWith(
                        clearFromDate: true,
                        clearToDate: true,
                      ),
                    ),
                    child: const Text(DiscProfile.adminReservationsClearDates),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: async.when(
            loading: () =>
                const DiscoveryListSkeleton(rowCount: 6, rowHeight: 88),
            error: (_, __) => DiscoveryEmptyState(
              icon: Icons.cloud_off_outlined,
              title: DiscProfile.adminBoutiqueLoadErr,
              body: CoreStrings.networkErrorBody,
              actionLabel: DiscList.retry,
              onAction: () =>
                  ref.invalidate(adminBoutiqueOrdersProvider(filters)),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                  child: Text(DiscProfile.adminBoutiqueOrdersEmpty),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(adminBoutiqueOrdersProvider(filters));
                  await ref.read(adminBoutiqueOrdersProvider(filters).future);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _AdminOrderCard(
                      order: items[index],
                      filters: filters,
                      dateFormat: dateFormat,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

enum _OrderAdminAction {
  confirmReceipt,
  setReady,
  setCompleted,
  cancel,
}

class _AdminOrderCard extends ConsumerWidget {
  const _AdminOrderCard({
    required this.order,
    required this.filters,
    required this.dateFormat,
  });

  final AdminBoutiqueOrderSummary order;
  final AdminBoutiqueOrderFilters filters;
  final DateFormat dateFormat;

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    _OrderAdminAction action,
  ) async {
    final title = switch (action) {
      _OrderAdminAction.confirmReceipt =>
        DiscProfile.adminBoutiqueActionConfirmReceipt,
      _OrderAdminAction.setReady => DiscProfile.adminBoutiqueActionSetReady,
      _OrderAdminAction.setCompleted =>
        DiscProfile.adminBoutiqueActionSetCompleted,
      _OrderAdminAction.cancel => DiscProfile.adminBoutiqueActionCancel,
    };
    final reason = await showAdminBoutiqueReasonDialog(
      context,
      title: title,
    );
    if (reason == null || !context.mounted) return;

    final service = ref.read(adminBoutiqueServiceProvider);
    if (service == null) return;

    try {
      switch (action) {
        case _OrderAdminAction.confirmReceipt:
          await service.confirmReceipt(
            commandeId: order.id,
            reason: reason,
          );
        case _OrderAdminAction.setReady:
          await service.setOrderStatut(
            commandeId: order.id,
            statut: 'ready',
            reason: reason,
          );
        case _OrderAdminAction.setCompleted:
          await service.setOrderStatut(
            commandeId: order.id,
            statut: 'completed',
            reason: reason,
          );
        case _OrderAdminAction.cancel:
          await service.setOrderStatut(
            commandeId: order.id,
            statut: 'canceled',
            reason: reason,
          );
      }
      ref.invalidate(adminBoutiqueOrdersProvider(filters));
      if (context.mounted) {
        AppSnackBar.success(context, DiscProfile.adminBoutiqueActionOk);
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.error(context, DiscProfile.adminBoutiqueActionErr);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final canConfirm = const {
      'ready',
      'preparing',
      'paid',
      'pay_on_site',
    }.contains(order.statut);
    final canCancel = order.statut != 'canceled' &&
        order.statut != 'completed';

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.prestataireSalon?.trim().isNotEmpty == true
                        ? order.prestataireSalon!
                        : DiscBoutique.clientOrdersUnknownSalon,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      order.clientName?.trim().isNotEmpty == true
                          ? order.clientName!
                          : DiscBoutique.ordersUnknownClient,
                      dateFormat.format(order.createdAt.toLocal()),
                      order.statut,
                      if (order.itemsCount > 0)
                        DiscProfile.adminBoutiqueItemsCount(order.itemsCount),
                    ].join(' · '),
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Text(
                        CurrencyFormat.eur(order.amountEuros, decimals: true),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (order.isPackLinked)
                        Chip(
                          label: const Text(DiscProfile.adminBoutiquePackBadge),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      if (order.hasAvis)
                        Chip(
                          label: const Text(DiscProfile.adminBoutiqueHasAvis),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<_OrderAdminAction>(
              onSelected: (a) => _run(context, ref, a),
              itemBuilder: (context) => [
                if (canConfirm)
                  const PopupMenuItem(
                    value: _OrderAdminAction.confirmReceipt,
                    child: Text(DiscProfile.adminBoutiqueActionConfirmReceipt),
                  ),
                if (order.statut != 'ready' && canCancel)
                  const PopupMenuItem(
                    value: _OrderAdminAction.setReady,
                    child: Text(DiscProfile.adminBoutiqueActionSetReady),
                  ),
                if (order.statut != 'completed')
                  const PopupMenuItem(
                    value: _OrderAdminAction.setCompleted,
                    child: Text(DiscProfile.adminBoutiqueActionSetCompleted),
                  ),
                if (canCancel)
                  const PopupMenuItem(
                    value: _OrderAdminAction.cancel,
                    child: Text(DiscProfile.adminBoutiqueActionCancel),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvisTab extends ConsumerWidget {
  const _AvisTab({
    required this.searchCtrl,
    required this.search,
    required this.dateFormat,
    required this.onSearch,
  });

  final TextEditingController searchCtrl;
  final String search;
  final DateFormat dateFormat;
  final ValueChanged<String> onSearch;

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AdminBoutiqueAvisSummary avis,
  ) async {
    final reason = await showAdminBoutiqueReasonDialog(
      context,
      title: DiscProfile.adminBoutiqueActionDeleteAvis,
    );
    if (reason == null || !context.mounted) return;
    final service = ref.read(adminBoutiqueServiceProvider);
    if (service == null) return;
    try {
      await service.deleteAvis(avisId: avis.id, reason: reason);
      ref.invalidate(adminBoutiqueAvisProvider(search));
      if (context.mounted) {
        AppSnackBar.success(context, DiscProfile.adminBoutiqueActionOk);
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.error(context, DiscProfile.adminBoutiqueActionErr);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminBoutiqueAvisProvider(search));
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: searchCtrl,
            decoration: const InputDecoration(
              labelText: DiscProfile.adminBoutiqueFilterSearch,
              prefixIcon: Icon(Icons.search),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (v) => onSearch(v.trim()),
          ),
        ),
        Expanded(
          child: async.when(
            loading: () =>
                const DiscoveryListSkeleton(rowCount: 6, rowHeight: 88),
            error: (_, __) => DiscoveryEmptyState(
              icon: Icons.cloud_off_outlined,
              title: DiscProfile.adminBoutiqueLoadErr,
              body: CoreStrings.networkErrorBody,
              actionLabel: DiscList.retry,
              onAction: () =>
                  ref.invalidate(adminBoutiqueAvisProvider(search)),
            ),
            data: (rows) {
              if (rows.isEmpty) {
                return const Center(
                  child: Text(DiscProfile.adminBoutiqueAvisEmpty),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(adminBoutiqueAvisProvider(search));
                  await ref.read(adminBoutiqueAvisProvider(search).future);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final a = rows[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          a.prestataireSalon?.trim().isNotEmpty == true
                              ? a.prestataireSalon!
                              : DiscBoutique.clientOrdersUnknownSalon,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          [
                            a.clientName?.trim().isNotEmpty == true
                                ? a.clientName!
                                : DiscBoutique.ordersUnknownClient,
                            DiscProfile.adminBoutiqueAvisNote(a.note),
                            dateFormat.format(a.createdAt.toLocal()),
                            if (a.commentaire?.trim().isNotEmpty == true)
                              a.commentaire!.trim(),
                          ].join(' · '),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          tooltip: DiscProfile.adminBoutiqueActionDeleteAvis,
                          onPressed: () => _delete(context, ref, a),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CatalogTab extends ConsumerWidget {
  const _CatalogTab({
    required this.searchCtrl,
    required this.search,
    required this.onSearch,
  });

  final TextEditingController searchCtrl;
  final String search;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminBoutiqueCatalogProvider(search));
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: searchCtrl,
            decoration: const InputDecoration(
              labelText: DiscProfile.adminBoutiqueFilterSearch,
              prefixIcon: Icon(Icons.search),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (v) => onSearch(v.trim()),
          ),
        ),
        Expanded(
          child: async.when(
            loading: () =>
                const DiscoveryListSkeleton(rowCount: 6, rowHeight: 88),
            error: (_, __) => DiscoveryEmptyState(
              icon: Icons.cloud_off_outlined,
              title: DiscProfile.adminBoutiqueLoadErr,
              body: CoreStrings.networkErrorBody,
              actionLabel: DiscList.retry,
              onAction: () =>
                  ref.invalidate(adminBoutiqueCatalogProvider(search)),
            ),
            data: (rows) {
              if (rows.isEmpty) {
                return const Center(
                  child: Text(DiscProfile.adminBoutiqueCatalogEmpty),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(adminBoutiqueCatalogProvider(search));
                  await ref.read(adminBoutiqueCatalogProvider(search).future);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final r = rows[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          r.prestataireSalon,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          [
                            if (r.ville?.trim().isNotEmpty == true) r.ville!,
                            DiscProfile.adminBoutiqueCatalogCounts(
                              produits: r.produitsActifs,
                              packs: r.packsActifs,
                              commandes: r.commandesOuvertes,
                            ),
                          ].join(' · '),
                        ),
                        trailing: r.commandesOuvertes > 0
                            ? Badge(
                                label: Text('${r.commandesOuvertes}'),
                                child: const Icon(
                                  Icons.shopping_bag_outlined,
                                ),
                              )
                            : const Icon(Icons.storefront_outlined),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

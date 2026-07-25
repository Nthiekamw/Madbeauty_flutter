import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../models/admin_boutique_order_filters.dart';
import '../providers/admin_boutique_provider.dart';
import '../widgets/admin_screen_scaffold.dart';

/// Liste admin des commandes boutique (+ aperçu catalogue).
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
  String _catalogSearch = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    _catalogSearchCtrl.dispose();
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
            tabs: const [
              Tab(text: DiscProfile.adminBoutiqueTabOrders),
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
    final theme = Theme.of(context);

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
                    final o = items[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          o.prestataireSalon?.trim().isNotEmpty == true
                              ? o.prestataireSalon!
                              : DiscBoutique.clientOrdersUnknownSalon,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          [
                            o.clientName?.trim().isNotEmpty == true
                                ? o.clientName!
                                : DiscBoutique.ordersUnknownClient,
                            dateFormat.format(o.createdAt.toLocal()),
                            o.statut,
                            if (o.itemsCount > 0)
                              DiscProfile.adminBoutiqueItemsCount(o.itemsCount),
                          ].join(' · '),
                        ),
                        trailing: Text(
                          CurrencyFormat.eur(o.amountEuros, decimals: true),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
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

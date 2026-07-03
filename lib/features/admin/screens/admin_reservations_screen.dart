import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/utils/currency_format.dart';
import '../models/admin_reservation_filters.dart';
import '../models/admin_reservation_summary.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../providers/admin_reservations_provider.dart';
import '../widgets/admin_screen_scaffold.dart';

class AdminReservationsScreen extends ConsumerStatefulWidget {
  const AdminReservationsScreen({super.key});

  @override
  ConsumerState<AdminReservationsScreen> createState() =>
      _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends ConsumerState<AdminReservationsScreen> {
  AdminReservationFilters _filters = const AdminReservationFilters();

  void _applyFilters(AdminReservationFilters next) {
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
    final reservationsAsync = ref.watch(adminReservationsProvider(_filters));
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');
    final dayFormat = DateFormat('dd/MM/yyyy', 'fr_FR');

    return AdminScreenScaffold(
      title: DiscProfile.actionAdminReservations,
      body: Column(
        children: [
          const AdminScreenIntroBanner(
            icon: Icons.payments_outlined,
            title: DiscProfile.adminReservationsIntroTitle,
            body: DiscProfile.adminReservationsIntroBody,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _filters.statut ?? '',
                  decoration: const InputDecoration(
                    labelText: DiscProfile.adminReservationsFilterStatut,
                  ),
                  items: AdminReservationFilters.allStatuts
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
                  onChanged: (value) => _applyFilters(
                    value == null || value.isEmpty
                        ? _filters.copyWith(clearStatut: true)
                        : _filters.copyWith(statut: value),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _filters.paymentStatus ?? '',
                  decoration: const InputDecoration(
                    labelText: DiscProfile.adminReservationsFilterPayment,
                  ),
                  items: AdminReservationFilters.allPaymentStatuses
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
                  onChanged: (value) => _applyFilters(
                    value == null || value.isEmpty
                        ? _filters.copyWith(clearPaymentStatus: true)
                        : _filters.copyWith(paymentStatus: value),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickFromDate,
                        icon: const Icon(Icons.date_range, size: 18),
                        label: Text(
                          _filters.fromDate == null
                              ? DiscProfile.adminReservationsFilterFrom
                              : dayFormat.format(_filters.fromDate!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickToDate,
                        icon: const Icon(Icons.date_range, size: 18),
                        label: Text(
                          _filters.toDate == null
                              ? DiscProfile.adminReservationsFilterTo
                              : dayFormat.format(_filters.toDate!),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_filters.fromDate != null || _filters.toDate != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _applyFilters(
                        _filters.copyWith(clearFromDate: true, clearToDate: true),
                      ),
                      child: const Text(DiscProfile.adminReservationsClearDates),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: reservationsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text(DiscProfile.adminReservationsEmpty),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminReservationsProvider(_filters));
                    await ref.read(adminReservationsProvider(_filters).future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _ReservationCard(
                      item: items[index],
                      dateFormat: dateFormat,
                    ),
                  ),
                );
              },
              loading: () => const DiscoveryListSkeleton(rowCount: 6),
              error: (_, __) => DiscoveryEmptyState(
                icon: Icons.cloud_off_outlined,
                title: CoreStrings.networkErrorTitle,
                body: CoreStrings.networkErrorBody,
                iconColor: Theme.of(context).colorScheme.error,
                actionLabel: DiscList.retry,
                onAction: () {
                  ref.invalidate(adminReservationsProvider(_filters));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.item, required this.dateFormat});

  final AdminReservationSummary item;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final amount = item.amountCents;
    final amountLabel = amount == null ? '—' : CurrencyFormat.eurCents(amount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.serviceName ?? 'Réservation',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '${item.clientName ?? 'Client'} → ${item.prestataireSalon ?? 'Prestataire'}',
            ),
            Text(dateFormat.format(item.dateHeure)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                Chip(label: Text(item.statut)),
                if (item.paymentStatus != null)
                  Chip(label: Text(item.paymentStatus!)),
                if (item.paymentMode != null)
                  Chip(label: Text(item.paymentMode!)),
              ],
            ),
            const SizedBox(height: 4),
            Text('Montant : $amountLabel'),
            if (item.stripePaymentIntentId != null)
              Text(
                'Réf. paiement archivé : ${item.stripePaymentIntentId}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
          ],
        ),
      ),
    );
  }
}

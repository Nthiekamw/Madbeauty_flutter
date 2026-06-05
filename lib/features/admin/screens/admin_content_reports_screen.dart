import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../models/admin_content_report.dart';
import '../providers/admin_content_reports_provider.dart';

class AdminContentReportsScreen extends ConsumerStatefulWidget {
  const AdminContentReportsScreen({super.key});

  @override
  ConsumerState<AdminContentReportsScreen> createState() =>
      _AdminContentReportsScreenState();
}

class _AdminContentReportsScreenState
    extends ConsumerState<AdminContentReportsScreen> {
  AdminContentReportFilter _filter = AdminContentReportFilter.pending;
  final Set<String> _busyIds = <String>{};
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reportsAsync = ref.watch(adminContentReportsProvider(_filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text(DiscProfile.actionAdminReports),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SegmentedButton<AdminContentReportFilter>(
              segments: const [
                ButtonSegment(
                  value: AdminContentReportFilter.pending,
                  label: Text(DiscProfile.adminReportsFilterPending),
                ),
                ButtonSegment(
                  value: AdminContentReportFilter.all,
                  label: Text(DiscProfile.adminReportsFilterAll),
                ),
              ],
              selected: {_filter},
              onSelectionChanged: (selected) {
                final next = selected.first;
                if (next == _filter) return;
                setState(() => _filter = next);
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: reportsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text(DiscProfile.adminReportsEmpty),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminContentReportsProvider(_filter));
                    await ref.read(
                      adminContentReportsProvider(_filter).future,
                    );
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _ReportCard(
                        item: item,
                        dateFormat: _dateFormat,
                        busy: _busyIds.contains(item.id),
                        onMarkReviewed: () => _markReviewed(item),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    err.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markReviewed(AdminContentReport item) async {
    final service = ref.read(adminContentReportsServiceProvider);
    if (service == null) return;
    setState(() => _busyIds.add(item.id));
    try {
      await service.markReviewed(reportId: item.id);
      ref.invalidate(adminContentReportsProvider(_filter));
      if (mounted) {
        AppSnackBar.show(
          context,
          message: DiscProfile.adminReportsMarkedReviewed,
          kind: AppSnackKind.success,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: DiscProfile.adminReportsMarkReviewedErr,
          kind: AppSnackKind.error,
        );
      }
    } finally {
      if (mounted) setState(() => _busyIds.remove(item.id));
    }
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.item,
    required this.dateFormat,
    required this.busy,
    required this.onMarkReviewed,
  });

  final AdminContentReport item;
  final DateFormat dateFormat;
  final bool busy;
  final VoidCallback onMarkReviewed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = item.details?.trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.displayTarget,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(
                    item.isReviewed
                        ? DiscProfile.adminReportsStatusReviewed
                        : DiscProfile.adminReportsStatusPending,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${item.targetTypeLabel} · ${dateFormat.format(item.createdAt.toLocal())}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text('Motif : ${item.reason}'),
            if (details != null && details.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Détails : $details'),
            ],
            const SizedBox(height: 8),
            Text('Signaleur : ${item.reporterLabel}'),
            if (item.reporterEmail != null &&
                item.reporterEmail!.trim().isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                item.reporterEmail!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'ID cible : ${item.targetId}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (!item.isReviewed) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  onPressed: busy ? null : onMarkReviewed,
                  child: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(DiscProfile.adminReportsMarkReviewed),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/disputes/dispute_providers.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../widgets/admin_discovery_widgets.dart';
import '../widgets/admin_screen_scaffold.dart';

class AdminDisputesScreen extends ConsumerStatefulWidget {
  const AdminDisputesScreen({super.key});

  @override
  ConsumerState<AdminDisputesScreen> createState() =>
      _AdminDisputesScreenState();
}

class _AdminDisputesScreenState extends ConsumerState<AdminDisputesScreen> {
  AdminDisputeFilter _filter = AdminDisputeFilter.open;
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final async = ref.watch(adminDisputesProvider(_filter));

    return AdminScreenScaffold(
      title: DiscDispute.adminScreenTitle,
      body: Column(
        children: [
          const AdminScreenIntroBanner(
            icon: Icons.gavel_outlined,
            title: DiscDispute.adminIntroTitle,
            body: DiscDispute.adminIntroBody,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AdminFilterSegment<AdminDisputeFilter>(
              segments: const [
                ButtonSegment(
                  value: AdminDisputeFilter.open,
                  label: Text(DiscDispute.adminFilterOpen),
                ),
                ButtonSegment(
                  value: AdminDisputeFilter.all,
                  label: Text(DiscDispute.adminFilterAll),
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
            child: async.when(
              loading: () =>
                  const DiscoveryListSkeleton(rowCount: 5, rowHeight: 88),
              error: (_, __) => DiscoveryEmptyState(
                icon: Icons.cloud_off_outlined,
                title: CoreStrings.networkErrorTitle,
                body: CoreStrings.networkErrorBody,
                iconColor: theme.colorScheme.error,
                actionLabel: DiscList.retry,
                onAction: () =>
                    ref.invalidate(adminDisputesProvider(_filter)),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const AdminListEmptyState(
                    icon: Icons.gavel_outlined,
                    title: DiscDispute.adminEmpty,
                    body: DiscDispute.adminIntroBody,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminDisputesProvider(_filter));
                    await ref.read(adminDisputesProvider(_filter).future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () =>
                              context.pushAdminDisputeDetail(item.id),
                          child: AdminDiscoveryCard(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          DiscDispute.reasonLabelOf(
                                            item.reason,
                                          ),
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        DiscDispute.statusLabelOf(item.status),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    [
                                      DiscDispute.openedByLabel(
                                        item.openedBy,
                                      ),
                                      _dateFormat
                                          .format(item.createdAt.toLocal()),
                                    ].join(' · '),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (item.summary?.trim().isNotEmpty ==
                                      true) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      item.summary!.trim(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
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
      ),
    );
  }
}

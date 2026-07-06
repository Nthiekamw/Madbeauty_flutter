import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/admin/admin_account_deletion_request.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../providers/admin_account_deletion_provider.dart';
import '../widgets/admin_discovery_widgets.dart';
import '../widgets/admin_screen_scaffold.dart';

class AdminAccountDeletionScreen extends ConsumerStatefulWidget {
  const AdminAccountDeletionScreen({super.key});

  @override
  ConsumerState<AdminAccountDeletionScreen> createState() =>
      _AdminAccountDeletionScreenState();
}

class _AdminAccountDeletionScreenState
    extends ConsumerState<AdminAccountDeletionScreen> {
  final Set<String> _busyIds = {};

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(adminAccountDeletionRequestsProvider);

    return AdminScreenScaffold(
      title: DiscProfile.actionAdminAccountDeletions,
      body: Column(
        children: [
          const AdminScreenIntroBanner(
            icon: Icons.person_remove_outlined,
            title: DiscProfile.adminAccountDeletionsIntroTitle,
            body: DiscProfile.adminAccountDeletionsIntroBody,
          ),
          Expanded(
            child: requestsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const AdminListEmptyState(
                    icon: Icons.person_remove_outlined,
                    title: DiscProfile.adminAccountDeletionsEmpty,
                    body: DiscProfile.adminAccountDeletionsIntroBody,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminAccountDeletionRequestsProvider);
                    await ref.read(adminAccountDeletionRequestsProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _RequestCard(
                      item: items[index],
                      busy: _busyIds.contains(items[index].userId),
                      onDelete: () => _executeDeletion(items[index]),
                    ),
                  ),
                );
              },
              loading: () => const DiscoveryListSkeleton(rowCount: 5),
              error: (_, __) => DiscoveryEmptyState(
                icon: Icons.cloud_off_outlined,
                title: CoreStrings.networkErrorTitle,
                body: DiscProfile.adminAccountDeletionsLoadErr,
                iconColor: Theme.of(context).colorScheme.error,
                actionLabel: DiscList.retry,
                onAction: () =>
                    ref.invalidate(adminAccountDeletionRequestsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeDeletion(AdminAccountDeletionRequest item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(DiscProfile.adminAccountDeletionDialogTitle(item.displayName)),
        content: const Text(DiscProfile.adminAccountDeletionDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(CoreStrings.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(DiscProfile.adminAccountDeletionConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final service = ref.read(adminAccountDeletionServiceProvider);
    if (service == null) return;

    setState(() => _busyIds.add(item.userId));
    try {
      await service.executeDeletion(userId: item.userId);
      ref.invalidate(adminAccountDeletionRequestsProvider);
      ref.invalidate(adminPendingAccountDeletionsCountProvider);
      if (mounted) {
        AppSnackBar.show(
          context,
          message: DiscProfile.adminAccountDeletionDone,
          kind: AppSnackKind.success,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(context, DiscProfile.adminAccountDeletionErr);
      }
    } finally {
      if (mounted) setState(() => _busyIds.remove(item.userId));
    }
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.item,
    required this.busy,
    required this.onDelete,
  });

  final AdminAccountDeletionRequest item;
  final bool busy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requestedAt = item.requestedAt?.toLocal();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.displayName, style: theme.textTheme.titleMedium),
            Text(item.email, style: theme.textTheme.bodySmall),
            if (requestedAt != null) ...[
              const SizedBox(height: 6),
              Text(
                DiscProfile.adminAccountDeletionRequestedAt(requestedAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (item.roles.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final role in item.roles)
                    Chip(
                      label: Text(role),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            if (busy)
              const LinearProgressIndicator()
            else
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                ),
                onPressed: onDelete,
                icon: const Icon(Icons.delete_forever_outlined, size: 20),
                label: const Text(DiscProfile.adminAccountDeletionExecute),
              ),
          ],
        ),
      ),
    );
  }
}

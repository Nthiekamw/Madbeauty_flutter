import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/bug_report.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/bug_report/bug_report_providers.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery/discovery_constrained_body.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_feature_header.dart';
import '../../../shared/widgets/app/app_network_image.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';

class MyBugReportsScreen extends ConsumerWidget {
  const MyBugReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reportsAsync = ref.watch(myBugReportsProvider);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');

    return DiscoveryBrandScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const DiscoveryFeatureHeader(
            title: DiscBug.myReportsTitle,
            icon: Icons.bug_report_outlined,
          ),
          Expanded(
            child: DiscoveryConstrainedBody(
              child: reportsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return DiscoveryEmptyState(
                      icon: Icons.bug_report_outlined,
                      title: DiscBug.myReportsEmpty,
                      body: DiscBug.actionReportHint,
                      actionLabel: DiscBug.actionReport,
                      onAction: () => context.pushReportBug(),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(myBugReportsProvider);
                      await ref.read(myBugReportsProvider.future);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => _BugReportTile(
                        item: items[index],
                        dateFormat: dateFormat,
                        theme: theme,
                        onOpenChat: () =>
                            context.pushBugReportChat(items[index].id),
                      ),
                    ),
                  );
                },
                loading: () => const DiscoveryListSkeleton(rowCount: 4),
                error: (_, __) => DiscoveryEmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: CoreStrings.networkErrorTitle,
                  body: CoreStrings.networkErrorBody,
                  actionLabel: DiscList.retry,
                  onAction: () => ref.invalidate(myBugReportsProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BugReportTile extends StatelessWidget {
  const _BugReportTile({
    required this.item,
    required this.dateFormat,
    required this.theme,
    required this.onOpenChat,
  });

  final BugReport item;
  final DateFormat dateFormat;
  final ThemeData theme;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) {
    final note = item.reporterMessage?.trim();
    final screenshot = item.screenshotUrl?.trim();

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  DiscBug.statusLabel(item.status),
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${DiscBug.categoryLabel(item.category)} · '
            '${dateFormat.format(item.createdAt.toLocal())}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(item.description),
          if (screenshot != null && screenshot.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AppNetworkImage(
                url: screenshot,
                height: 140,
                width: double.infinity,
              ),
            ),
          ],
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              note,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onOpenChat,
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text(DiscBug.openChat),
          ),
        ],
      ),
    );
  }
}

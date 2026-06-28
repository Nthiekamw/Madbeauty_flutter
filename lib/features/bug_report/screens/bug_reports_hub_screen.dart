import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/bug_report/bug_report_providers.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/layout/profile_flow_scaffold.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../widgets/bug_report_list_tile.dart';
import '../widgets/bug_report_new_cta_card.dart';

/// Hub signalements : liste + action pour créer un nouveau bug.
class BugReportsHubScreen extends ConsumerWidget {
  const BugReportsHubScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(myBugReportsProvider);
    await ref.read(myBugReportsProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reportsAsync = ref.watch(myBugReportsProvider);
    final dateFormat = DateFormat('dd MMM yyyy · HH:mm', 'fr_FR');
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;
    final listPadding = useWeb
        ? const EdgeInsets.fromLTRB(20, 16, 20, 32)
        : const EdgeInsets.fromLTRB(20, 4, 20, 32);

    return ProfileFlowScaffold(
      title: DiscBug.screenTitle,
      subtitle: DiscBug.hubSubtitle,
      icon: Icons.bug_report_outlined,
      body: reportsAsync.when(
        data: (items) {
          return RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: listPadding,
              children: [
                BugReportNewCtaCard(
                  onTap: () => context.pushNewBugReport(),
                ),
                const SizedBox(height: 24),
                Text(
                  DiscBug.myReportsSectionTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  items.isEmpty
                      ? DiscBug.myReportsEmpty
                      : DiscBug.myReportsCountLabel(items.length),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: AppFonts.body,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  DiscoveryEmptyState(
                    icon: Icons.inbox_outlined,
                    title: DiscBug.myReportsEmpty,
                    body: DiscBug.myReportsEmptyBody,
                    iconColor: AppColors.brandBrownMid,
                  )
                else
                  ...[
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      BugReportListTile(
                        item: items[i],
                        dateFormat: dateFormat,
                        onTap: () => context.pushBugReportChat(items[i].id),
                      ),
                    ],
                  ],
              ],
            ),
          );
        },
        loading: () => ListView(
          padding: listPadding,
          children: const [
            SizedBox(
              height: 96,
              child: DiscoveryListSkeleton(rowCount: 1, rowHeight: 96),
            ),
            SizedBox(height: 24),
            DiscoveryListSkeleton(rowCount: 3, rowHeight: 120),
          ],
        ),
        error: (_, __) => RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: listPadding,
            children: [
              BugReportNewCtaCard(
                onTap: () => context.pushNewBugReport(),
              ),
              const SizedBox(height: 24),
              DiscoveryEmptyState(
                icon: Icons.cloud_off_outlined,
                title: CoreStrings.networkErrorTitle,
                body: CoreStrings.networkErrorBody,
                actionLabel: DiscList.retry,
                onAction: () => ref.invalidate(myBugReportsProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

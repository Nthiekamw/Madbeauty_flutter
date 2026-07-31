import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../providers/admin_pending_counts_provider.dart';
import '../providers/admin_user_support_provider.dart';
import '../widgets/admin_hub_action_tile.dart';
import '../widgets/admin_screen_scaffold.dart';

class AdminSupportHubScreen extends ConsumerWidget {
  const AdminSupportHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = DiscoveryResponsive.of(context);
    final pendingBugs = ref.watch(adminPendingBugReportsCountProvider);
    final supportUnread = ref.watch(adminUserSupportUnreadCountProvider);

    return AdminScreenScaffold(
      title: ShellStrings.navAdminSupport,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          responsive.horizontalPadding,
          8,
          responsive.horizontalPadding,
          24,
        ),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: responsive.contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AdminScreenIntroBanner(
                    icon: Icons.support_agent_rounded,
                    title: DiscProfile.adminSupportHubTitle,
                    body: DiscProfile.adminSupportHubBody,
                  ),
                  const SizedBox(height: 16),
                  AdminHubActionGrid(
                    children: [
                      AdminHubActionTile(
                        icon: Icons.bug_report_outlined,
                        title: DiscProfile.actionAdminBugReports,
                        subtitle: DiscProfile.actionAdminBugReportsHint,
                        badge: pendingBugs.maybeWhen(
                          data: (c) => c,
                          orElse: () => 0,
                        ),
                        onTap: () => context.pushAdminBugReports(),
                      ),
                      AdminHubActionTile(
                        icon: Icons.forum_outlined,
                        title: DiscProfile.actionAdminUserSupport,
                        subtitle: DiscProfile.actionAdminUserSupportHint,
                        badge: supportUnread.maybeWhen(
                          data: (c) => c,
                          orElse: () => 0,
                        ),
                        onTap: () => context.pushAdminUserSupport(),
                      ),
                      AdminHubActionTile(
                        icon: Icons.gavel_outlined,
                        title: DiscDispute.adminHubTitle,
                        subtitle: DiscDispute.adminHubHint,
                        onTap: () => context.pushAdminDisputes(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../providers/admin_account_deletion_provider.dart';
import '../widgets/admin_hub_action_tile.dart';
import '../widgets/admin_screen_scaffold.dart';

class AdminManagementHubScreen extends ConsumerWidget {
  const AdminManagementHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = DiscoveryResponsive.of(context);
    final pendingDeletions =
        ref.watch(adminPendingAccountDeletionsCountProvider);

    return AdminScreenScaffold(
      title: ShellStrings.navAdminManagement,
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
                    icon: Icons.tune_rounded,
                    title: DiscProfile.adminManagementHubTitle,
                    body: DiscProfile.adminManagementHubBody,
                  ),
                  const SizedBox(height: 16),
                  AdminHubActionGrid(
                    children: [
                      AdminHubActionTile(
                        icon: Icons.people_outline,
                        title: DiscProfile.actionAdminUsers,
                        subtitle: DiscProfile.actionAdminUsersHint,
                        onTap: () => context.pushAdminUsers(),
                      ),
                      AdminHubActionTile(
                        icon: Icons.person_remove_outlined,
                        title: DiscProfile.actionAdminAccountDeletions,
                        subtitle: DiscProfile.actionAdminAccountDeletionsHint,
                        badge: pendingDeletions.maybeWhen(
                          data: (c) => c,
                          orElse: () => 0,
                        ),
                        onTap: () => context.pushAdminAccountDeletions(),
                      ),
                      AdminHubActionTile(
                        icon: Icons.payments_outlined,
                        title: DiscProfile.actionAdminReservations,
                        subtitle: DiscProfile.actionAdminReservationsHint,
                        onTap: () => context.pushAdminReservations(),
                      ),
                      AdminHubActionTile(
                        icon: Icons.card_giftcard_outlined,
                        title: DiscProfile.actionAdminSubscriptionTrial,
                        subtitle: DiscProfile.actionAdminSubscriptionTrialHint,
                        onTap: () => context.pushAdminSubscriptionTrial(),
                      ),
                      AdminHubActionTile(
                        icon: Icons.euro_outlined,
                        title: DiscProfile.actionAdminBookingPlatformFee,
                        subtitle: DiscProfile.actionAdminBookingPlatformFeeHint,
                        onTap: () => context.pushAdminBookingPlatformFee(),
                      ),
                      AdminHubActionTile(
                        icon: Icons.notifications_active_outlined,
                        title: DiscProfile.actionAdminPush,
                        subtitle: DiscProfile.actionAdminPushHint,
                        onTap: () => context.pushAdminPush(),
                      ),
                      AdminHubActionTile(
                        icon: Icons.history,
                        title: DiscProfile.actionAdminAudit,
                        subtitle: DiscProfile.actionAdminAuditHint,
                        onTap: () => context.pushAdminAudit(),
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

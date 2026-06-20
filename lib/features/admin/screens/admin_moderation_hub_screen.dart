import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../providers/admin_pending_counts_provider.dart';
import '../widgets/admin_hub_action_tile.dart';
import '../widgets/admin_screen_scaffold.dart';

class AdminModerationHubScreen extends ConsumerWidget {
  const AdminModerationHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = DiscoveryResponsive.of(context);
    final pendingVerifications =
        ref.watch(adminPendingVerificationsCountProvider);
    final pendingReports = ref.watch(adminPendingReportsCountProvider);

    return AdminScreenScaffold(
      title: ShellStrings.navAdminModeration,
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
                    icon: Icons.gavel_rounded,
                    title: DiscProfile.adminModerationHubTitle,
                    body: DiscProfile.adminModerationHubBody,
                  ),
                  const SizedBox(height: 16),
                  AdminHubActionGrid(
                    children: [
                      AdminHubActionTile(
                        icon: Icons.verified_user_outlined,
                        title: DiscProfile.actionAdminVerifications,
                        subtitle: DiscProfile.actionAdminVerificationsHint,
                        badge: pendingVerifications.maybeWhen(
                          data: (c) => c,
                          orElse: () => 0,
                        ),
                        onTap: () => context.pushAdminVerifications(),
                      ),
                      AdminHubActionTile(
                        icon: Icons.flag_outlined,
                        title: DiscProfile.actionAdminReports,
                        subtitle: DiscProfile.actionAdminReportsHint,
                        badge: pendingReports.maybeWhen(
                          data: (c) => c,
                          orElse: () => 0,
                        ),
                        onTap: () => context.pushAdminReports(),
                      ),
                      AdminHubActionTile(
                        icon: Icons.photo_library_outlined,
                        title: DiscProfile.actionAdminRealisationPhotos,
                        subtitle: DiscProfile.actionAdminRealisationPhotosHint,
                        onTap: () => context.pushAdminRealisationPhotos(),
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

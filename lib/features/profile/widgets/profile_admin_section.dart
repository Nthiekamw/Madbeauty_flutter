import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/user_role.dart';
import '../../../features/auth/providers/my_roles_provider.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/widgets/discovery/discovery_menu_tile.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import 'profile_section_title.dart';

class ProfileAdminSection extends ConsumerWidget {
  const ProfileAdminSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(myRolesProvider).value ?? const <UserRole>[];
    final isAdmin = roles.contains(UserRole.admin);
    if (!isAdmin) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProfileSectionTitle(title: DiscProfile.sectionAdmin),
        DiscoverySurfaceCard(
          child: Column(
            children: [
              DiscoveryMenuTile(
                icon: Icons.admin_panel_settings_outlined,
                title: DiscProfile.actionAdminVerifications,
                subtitle: DiscProfile.actionAdminVerificationsHint,
                onTap: () => context.pushAdminVerifications(),
              ),
              const Divider(height: 1),
              DiscoveryMenuTile(
                icon: Icons.flag_outlined,
                title: DiscProfile.actionAdminReports,
                subtitle: DiscProfile.actionAdminReportsHint,
                onTap: () => context.pushAdminReports(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


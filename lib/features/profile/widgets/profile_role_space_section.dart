import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../auth/widgets/role_switch_section.dart';
import 'profile_section_title.dart';

/// Section profil : bascule d’espace ou parcours « devenir prestataire ».
class ProfileRoleSpaceSection extends StatelessWidget {
  const ProfileRoleSpaceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProfileSectionTitle(title: DiscProfile.roleSpaceTitle),
        DiscoverySurfaceCard(
          padding: const EdgeInsets.all(14),
          child: RoleSwitchSection(
            showHeader: false,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

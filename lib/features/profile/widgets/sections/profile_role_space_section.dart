import 'package:flutter/material.dart';

import '../../../auth/widgets/role_switch_section.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';

/// Section profil : « Mon espace » sur une ligne + 2 colonnes client / prestataire.
class ProfileRoleSpaceSection extends StatelessWidget {
  const ProfileRoleSpaceSection({
    super.key,
    this.showHeader = true,
  });

  /// Masquer le titre interne si un en-tête de section parent l’affiche déjà.
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return DiscoverySurfaceCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: RoleSwitchSection(
        showHeader: showHeader,
        compact: true,
        forceTwoColumns: true,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

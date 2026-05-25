import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/widgets/discovery_surface_card.dart';
import 'prestataire_section_header.dart';

/// Rappel compact sur le dashboard : la gestion du profil est dans l’onglet Profil.
class PrestataireProfileIncompleteBanner extends StatelessWidget {
  const PrestataireProfileIncompleteBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: DiscoverySurfaceCard(
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.goPrestataireProfile(),
            borderRadius: DiscoveryStyles.cardBorderRadius,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: PrestataireSectionHeader(
                      icon: Icons.person_outline_rounded,
                      title: DiscPrestaDash.profileIncompleteTitle,
                      subtitle: DiscPrestaDash.profileIncompleteBanner,
                      iconColor: theme.colorScheme.tertiary,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

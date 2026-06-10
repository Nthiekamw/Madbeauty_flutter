import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../../../../shared/theme/discovery_styles.dart';
import '../../../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../shared/prestataire_section_header.dart';

/// Raccourci abonnement sur le dashboard prestataire.
class PrestataireDashboardSubscriptionBanner extends StatelessWidget {
  const PrestataireDashboardSubscriptionBanner({super.key});

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
            onTap: () => context.pushPrestataireSubscription(),
            borderRadius: DiscoveryStyles.cardBorderRadius,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: PrestataireSectionHeader(
                      icon: Icons.card_membership_rounded,
                      title: DiscPrestaSub.dashboardBannerTitle,
                      subtitle: DiscPrestaSub.dashboardBannerBody,
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

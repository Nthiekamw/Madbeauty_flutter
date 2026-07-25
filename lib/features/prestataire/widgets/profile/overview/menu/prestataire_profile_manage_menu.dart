import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../router/navigation_extensions.dart';
import '../../../../../../../shared/widgets/discovery/discovery_menu_tile.dart';
import '../../../../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../../models/prestataire_profile_edit_section.dart';
import '../../../shared/prestataire_section_header.dart';

/// Raccourcis pour modifier chaque bloc du profil prestataire.
class PrestataireProfileManageMenu extends StatelessWidget {
  const PrestataireProfileManageMenu({
    super.key,
    this.showHeader = true,
    this.padding = EdgeInsets.zero,
  });

  final bool showHeader;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = PrestataireProfileEditSection.values
        .where((s) => s != PrestataireProfileEditSection.horaires)
        .toList();

    final card = DiscoverySurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeader)
            PrestataireSectionHeader(
              icon: Icons.storefront_rounded,
              title: DiscPrestaProfile.sectionPro,
              subtitle: DiscPrestaProfile.sectionProHint,
              iconColor: theme.colorScheme.primary,
            ),
          if (showHeader) const SizedBox(height: 8),
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 4,
                endIndent: 4,
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
              ),
            DiscoveryMenuTile(
              icon: sections[i].icon,
              title: sections[i].menuTitle,
              subtitle: sections[i].menuSubtitle,
              onTap: () =>
                  context.pushPrestataireProfileEditSection(sections[i]),
            ),
          ],
          Divider(
            height: 1,
            indent: 4,
            endIndent: 4,
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
          DiscoveryMenuTile(
            icon: Icons.rate_review_outlined,
            title: DiscReview.receivedReviewsTitle,
            subtitle: DiscReview.receivedReviewsSubtitle,
            onTap: () => context.pushPrestataireReceivedReviews(),
          ),
          Divider(
            height: 1,
            indent: 4,
            endIndent: 4,
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
          DiscoveryMenuTile(
            icon: Icons.schedule_rounded,
            title: DiscPrestaProfile.horaires,
            subtitle: DiscPrestaProfile.menuHorairesHint,
            onTap: () => context.pushPrestataireHoraires(),
          ),
          Divider(
            height: 1,
            indent: 4,
            endIndent: 4,
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
          DiscoveryMenuTile(
            icon: Icons.movie_filter_outlined,
            title: DiscReel.menuTitle,
            subtitle: DiscReel.menuHint,
            onTap: () => context.pushPrestataireReel(),
          ),
          Divider(
            height: 1,
            indent: 4,
            endIndent: 4,
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
          DiscoveryMenuTile(
            icon: Icons.storefront_outlined,
            title: DiscBoutique.menuBoutique,
            subtitle: DiscBoutique.menuBoutiqueHint,
            onTap: () => context.pushPrestataireBoutique(),
          ),
          Divider(
            height: 1,
            indent: 4,
            endIndent: 4,
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
          DiscoveryMenuTile(
            icon: Icons.local_offer_outlined,
            title: DiscBoutique.menuPacks,
            subtitle: DiscBoutique.menuPacksHint,
            onTap: () => context.pushPrestatairePacks(),
          ),
          Divider(
            height: 1,
            indent: 4,
            endIndent: 4,
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
          DiscoveryMenuTile(
            icon: Icons.receipt_long_outlined,
            title: DiscBoutique.menuOrders,
            subtitle: DiscBoutique.menuOrdersHint,
            onTap: () => context.pushPrestataireBoutiqueOrders(),
          ),
        ],
      ),
    );

    if (padding == EdgeInsets.zero) return card;
    return Padding(padding: padding, child: card);
  }
}

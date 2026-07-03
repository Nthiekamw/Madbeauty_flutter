import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/widgets/discovery/discovery_menu_tile.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../auth/guest/guest_mode_provider.dart';
import '../layout/profile_section_title.dart';

class ProfileAccountSection extends ConsumerWidget {
  const ProfileAccountSection({
    super.key,
    this.topSection,
    this.menuPrefix,
    this.showClientReviews = true,
  });

  /// Contenu optionnel au-dessus des entrées compte.
  final Widget? topSection;

  /// Tuiles insérées en tête du menu compte (ex. abonnement prestataire).
  final Widget? menuPrefix;

  /// « Mes avis » (avis laissés en tant que cliente). Masqué sur le profil prestataire.
  final bool showClientReviews;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestBrowsingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProfileSectionTitle(
          title: DiscProfile.sectionAccount,
          icon: Icons.manage_accounts_outlined,
        ),
        if (topSection != null) ...[
          topSection!,
          const SizedBox(height: 10),
        ],
        DiscoverySurfaceCard(
          child: Column(
            children: [
              if (menuPrefix != null) ...[
                menuPrefix!,
                _divider(context),
              ],
              DiscoveryMenuTile(
                icon: Icons.person_outline_rounded,
                title: DiscProfile.actionEditAccount,
                onTap: () => context.pushEditClientAccount(),
              ),
              if (showClientReviews) ...[
                _divider(context),
                DiscoveryMenuTile(
                  icon: Icons.rate_review_outlined,
                  title: DiscProfile.actionReviews,
                  subtitle: DiscReview.myReviewsSubtitle,
                  onTap: () => context.pushClientReviews(),
                ),
              ],
              _divider(context),
              DiscoveryMenuTile(
                icon: Icons.history_rounded,
                title: DiscProfile.actionHistory,
                onTap: () => context.pushClientHistory(),
              ),
              _divider(context),
              DiscoveryMenuTile(
                icon: Icons.card_giftcard_rounded,
                title: DiscProfile.actionReferral,
                subtitle: DiscProfile.actionReferralHint,
                onTap: isGuest ? null : () => context.pushClientReferral(),
              ),
              _divider(context),
              DiscoveryMenuTile(
                icon: Icons.bug_report_outlined,
                title: DiscBug.actionReport,
                subtitle: DiscBug.actionReportHint,
                onTap: isGuest ? null : () => context.pushReportBug(),
              ),
              _divider(context),
              DiscoveryMenuTile(
                icon: Icons.help_outline_rounded,
                title: DiscProfile.actionHelp,
                onTap: () => context.pushClientHelp(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
    );
  }
}

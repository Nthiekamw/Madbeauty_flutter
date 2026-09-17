import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/stripe_platform_policy.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/theme/app_icons.dart';
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
    this.showClientPrograms = true,
  });

  /// Contenu optionnel au-dessus des entrées compte.
  final Widget? topSection;

  /// Tuiles insérées en tête du menu compte (ex. abonnement prestataire).
  final Widget? menuPrefix;

  /// « Mes avis » (avis laissés en tant que cliente). Masqué sur le profil prestataire.
  final bool showClientReviews;

  /// Fidélité, wishlist, parrainage, historique client. Masqué côté prestataire.
  final bool showClientPrograms;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestBrowsingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProfileSectionTitle(
          title: DiscProfile.sectionAccount,
          icon: AppIcons.account,
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
                icon: AppIcons.profile,
                title: DiscProfile.actionEditAccount,
                onTap: () => context.pushEditClientAccount(),
              ),
              if (showClientPrograms && StripePlatformPolicy.isEnabled) ...[
                _divider(context),
                DiscoveryMenuTile(
                  icon: AppIcons.creditCard,
                  title: DiscPaymentMethods.sectionTitle,
                  subtitle: DiscPaymentMethods.clientSectionSubtitle,
                  onTap: () => context.pushClientPaymentMethods(),
                ),
              ],
              if (showClientReviews) ...[
                _divider(context),
                DiscoveryMenuTile(
                  icon: AppIcons.reviews,
                  title: DiscProfile.actionReviews,
                  subtitle: DiscReview.myReviewsSubtitle,
                  onTap: () => context.pushClientReviews(),
                ),
              ],
              if (showClientPrograms) ...[
                _divider(context),
                DiscoveryMenuTile(
                  icon: AppIcons.history,
                  title: DiscProfile.actionHistory,
                  onTap: () => context.pushClientHistory(),
                ),
                _divider(context),
                DiscoveryMenuTile(
                  icon: AppIcons.loyalty,
                  title: DiscProfile.actionLoyalty,
                  subtitle: DiscProfile.actionLoyaltyHint,
                  onTap: isGuest ? null : () => context.pushClientLoyalty(),
                ),
                _divider(context),
                DiscoveryMenuTile(
                  icon: AppIcons.wishlist,
                  title: DiscWishlist.profileSectionTitle,
                  subtitle: DiscWishlist.profileSectionHint,
                  onTap: isGuest ? null : () => context.pushClientWishlist(),
                ),
                _divider(context),
                DiscoveryMenuTile(
                  icon: AppIcons.referral,
                  title: DiscProfile.actionReferral,
                  subtitle: DiscProfile.actionReferralHint,
                  onTap: isGuest ? null : () => context.pushClientReferral(),
                ),
              ],
              _divider(context),
              DiscoveryMenuTile(
                icon: AppIcons.bug,
                title: DiscBug.actionReport,
                subtitle: DiscBug.actionReportHint,
                onTap: isGuest ? null : () => context.pushReportBug(),
              ),
              _divider(context),
              DiscoveryMenuTile(
                icon: AppIcons.help,
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

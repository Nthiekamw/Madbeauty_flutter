import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../profile/widgets/account/profile_account_section.dart';
import '../../profile/widgets/sections/profile_appearance_section.dart';
import '../../profile/widgets/sections/profile_preferences_section.dart';
import '../../profile/widgets/sections/profile_pwa_install_section.dart';
import '../widgets/profile/overview/layout/prestataire_profile_insets.dart';
import '../widgets/profile/overview/menu/prestataire_profile_account_menu.dart';
import '../widgets/prestataire_verification_request_card.dart';
import '../widgets/shared/prestataire_section_header.dart';

/// Hub Compte : apparence, préférences, vérification, paramètres.
class PrestataireAccountHubScreen extends ConsumerWidget {
  const PrestataireAccountHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final padding = PrestataireProfileInsets.page(context);

    return Scaffold(
      appBar: AppBar(title: const Text(DiscPrestaProfile.hubCompteScreenTitle)),
      body: ListView(
        padding: padding.copyWith(bottom: 32),
        children: [
          PrestataireSectionHeader(
            icon: Icons.manage_accounts_outlined,
            title: DiscPrestaProfile.hubCompteScreenTitle,
            subtitle: DiscPrestaProfile.hubCompteScreenSubtitle,
            iconColor: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const PrestataireVerificationRequestCard(),
          const SizedBox(height: PrestataireProfileInsets.sectionTop),
          const ProfileAppearanceSection(),
          const SizedBox(height: PrestataireProfileInsets.sectionTop),
          const ProfilePreferencesSection(),
          const SizedBox(height: PrestataireProfileInsets.sectionTop),
          const ProfilePwaInstallSection(),
          const SizedBox(height: PrestataireProfileInsets.sectionTop),
          const ProfileAccountSection(
            menuPrefix: PrestataireProfileAccountMenu(),
            showClientReviews: false,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/market_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/app_appearance_provider.dart';
import '../../../../core/providers/market_country_provider.dart';
import '../../../../shared/widgets/discovery/discovery_menu_tile.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../appearance/appearance_settings_sheet.dart';
import '../layout/profile_section_title.dart';

/// Thème et langue — ouvre un panneau de réglages.
class ProfileAppearanceSection extends ConsumerWidget {
  const ProfileAppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appAppearanceProvider);
    final marketCountry = ref.watch(marketCountryProvider);
    final locale = appearance.locale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileSectionTitle(
          title: DiscAppearance.sectionTitle(locale),
          icon: Icons.palette_outlined,
        ),
        DiscoverySurfaceCard(
          child: DiscoveryMenuTile(
            icon: Icons.palette_outlined,
            title: DiscAppearance.tileTitle(locale),
            subtitle: DiscAppearance.tileSubtitle(
              locale,
              themeLabel: themeModeLabel(appearance.themeMode, locale),
              languageLabel: languageLabel(appearance.language, locale),
              marketLabel: MarketConfig.labelFor(marketCountry, locale),
            ),
            onTap: () => showAppearanceSettingsSheet(context),
          ),
        ),
      ],
    );
  }
}

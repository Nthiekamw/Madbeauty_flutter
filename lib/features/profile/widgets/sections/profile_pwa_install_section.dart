import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../pwa/logic/pwa_install_actions.dart';
import '../../../pwa/providers/pwa_install_provider.dart';
import '../layout/profile_section_title.dart';

/// Installation PWA — visible uniquement sur **Flutter Web mobile** (pas iOS/Android natifs).
class ProfilePwaInstallSection extends ConsumerWidget {
  const ProfilePwaInstallSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kIsWeb) return const SizedBox.shrink();

    final layout = DiscoveryResponsive.of(context);
    if (layout.useWebSiteLayout) return const SizedBox.shrink();

    final state = ref.watch(pwaInstallProvider);
    if (!state.profileInstallAvailable) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final actionLabel = state.showIosInstructions
        ? DiscPwa.profileInstallIosAction
        : DiscPwa.profileInstallAction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProfileSectionTitle(
          title: DiscPwa.profileSectionTitle,
          icon: Icons.install_mobile_rounded,
        ),
        DiscoverySurfaceCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_to_home_screen_rounded,
                        color: primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DiscPwa.profileInstallTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontFamily: AppFonts.display,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DiscPwa.profileInstallSubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => handlePwaInstallTap(context, ref, state),
                  icon: const Icon(Icons.install_mobile_rounded, size: 20),
                  label: Text(actionLabel),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

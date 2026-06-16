import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../providers/subscription/prestataire_subscription_gate_provider.dart';
import '../../providers/subscription/platform_catalog_trial_provider.dart';
import '../profile/overview/layout/prestataire_profile_insets.dart';
import '../shared/prestataire_section_header.dart';

/// Bandeau informatif pendant l’essai catalogue gratuit.
class PrestataireCatalogTrialBanner extends ConsumerWidget {
  const PrestataireCatalogTrialBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inTrial = ref.watch(prestataireIsInCatalogTrialProvider);
    final days = ref.watch(prestataireCatalogTrialDaysRemainingProvider);
    final platformTrialDays = ref.watch(platformCatalogTrialDaysProvider).maybeWhen(
          data: (d) => d,
          orElse: () => days ?? 90,
        );
    if (!inTrial || days == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const accent = AppColors.success;

    return Padding(
      padding: PrestataireProfileInsets.page(context).copyWith(
        top: 12,
        bottom: 4,
      ),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.pushPrestataireSubscription(),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: accent.withValues(alpha: isDark ? 0.14 : 0.1),
              border: Border.all(
                color: accent.withValues(alpha: isDark ? 0.55 : 0.45),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          DiscPrestaSub.trialBadge(platformTrialDays),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  PrestataireSectionHeader(
                    icon: Icons.timer_outlined,
                    title: DiscPrestaSub.trialBannerTitle,
                    subtitle: DiscPrestaSub.trialBannerBody(days),
                    iconColor: accent,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.pushPrestataireSubscription(),
                    child: Text(DiscPrestaSub.trialBannerCta),
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

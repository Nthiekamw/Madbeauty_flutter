import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/config/prestataire_subscription_config.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/widgets/discovery/content/discovery_shimmer.dart';
import '../../../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../providers/subscription/prestataire_subscription_provider.dart';
import '../../../providers/subscription/platform_catalog_trial_provider.dart';
import 'prestataire_subscription_checkout_section.dart';
import 'prestataire_subscription_tier_cards.dart';

/// Etape ou encart abonnement (inscription / hub) avec paiement Stripe.
class PrestataireSubscriptionOnboardingPanel extends ConsumerWidget {
  const PrestataireSubscriptionOnboardingPanel({
    super.key,
    this.compact = false,
    this.showViewDetailsLink = true,
    this.embeddedInHub = false,
  });

  final bool compact;
  final bool showViewDetailsLink;
  final bool embeddedInHub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final serviceCountAsync = ref.watch(
      prestatairePublishedServiceCountProvider,
    );
    final trialDaysAsync = ref.watch(platformCatalogTrialDaysProvider);

    return serviceCountAsync.when(
      loading: () => const DiscoveryInlineSkeleton(
        height: 120,
        padding: EdgeInsets.all(24),
      ),
      error: (_, __) => DiscoverySectionError(
        message: DiscPrestaDash.loadErr,
        onRetry: () => ref.invalidate(prestatairePublishedServiceCountProvider),
      ),
      data: (serviceCount) {
        final currentTier = PrestataireSubscriptionConfig.tierForServiceCount(
          serviceCount,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (compact) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: theme.colorScheme.secondaryContainer.withValues(
                    alpha: 0.45,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: trialDaysAsync.when(
                        data: (days) => Text(
                          DiscPrestaSub.onboardingCompactHint(days),
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        loading: () => Text(
                          DiscPrestaSub.onboardingCompactHint(
                            PrestataireSubscriptionConfig.catalogTrialDays,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        error: (_, __) => Text(
                          DiscPrestaSub.onboardingCompactHint(
                            PrestataireSubscriptionConfig.catalogTrialDays,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ] else ...[
              Text(
                DiscPrestaSub.onboardingTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              trialDaysAsync.when(
                data: (days) => Text(
                  DiscPrestaSub.onboardingBody(days),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                loading: () => Text(
                  DiscPrestaSub.onboardingBody(
                    PrestataireSubscriptionConfig.catalogTrialDays,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                error: (_, __) => Text(
                  DiscPrestaSub.onboardingBody(
                    PrestataireSubscriptionConfig.catalogTrialDays,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            _buildTierSummaryCard(
              context: context,
              theme: theme,
              primary: primary,
              serviceCount: serviceCount,
              currentTierId: currentTier.id,
              embeddedInHub: embeddedInHub,
            ),
            const SizedBox(height: 10),
            PrestataireSubscriptionTierCards(
              currentTierId: currentTier.id,
              compact: compact,
            ),
            const SizedBox(height: 12),
            PrestataireSubscriptionCheckoutSection(compact: compact),
            if (showViewDetailsLink) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.pushPrestataireSubscription(),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text(DiscPrestaSub.viewFullDetails),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

Widget _buildTierSummaryCard({
  required BuildContext context,
  required ThemeData theme,
  required Color primary,
  required int serviceCount,
  required String currentTierId,
  required bool embeddedInHub,
}) {
  final body = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        DiscPrestaSub.currentTier,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: primary,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        DiscPrestaSub.serviceCount.replaceFirst('%s', '$serviceCount'),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        currentTierId == 'solo' ? DiscPrestaSub.tierSolo : DiscPrestaSub.tierMulti,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );

  if (embeddedInHub) {
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: theme.colorScheme.surface.withValues(alpha: isDark ? 0.92 : 0.98),
      elevation: 0,
      surfaceTintColor: AppColors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: body),
    );
  }
  return DiscoverySurfaceCard(padding: const EdgeInsets.all(14), child: body);
}

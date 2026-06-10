import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/config/prestataire_subscription_config.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../providers/subscription/prestataire_subscription_provider.dart';
import 'prestataire_subscription_checkout_section.dart';

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

    return serviceCountAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Text(
        DiscPrestaDash.loadErr,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
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
                      child: Text(
                        DiscPrestaSub.onboardingCompactHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.35,
                          fontWeight: FontWeight.w600,
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
              Text(
                DiscPrestaSub.onboardingBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
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
            _TierRow(
              theme: theme,
              primary: primary,
              title: DiscPrestaSub.tierSolo,
              monthly: PrestataireSubscriptionConfig.solo.monthlyEur,
              yearly: PrestataireSubscriptionConfig.solo.yearlyEur,
              highlighted:
                  currentTier.id == PrestataireSubscriptionConfig.solo.id,
              compact: compact,
            ),
            const SizedBox(height: 8),
            _TierRow(
              theme: theme,
              primary: primary,
              title: DiscPrestaSub.tierMulti,
              monthly: PrestataireSubscriptionConfig.multi.monthlyEur,
              yearly: PrestataireSubscriptionConfig.multi.yearlyEur,
              highlighted:
                  currentTier.id == PrestataireSubscriptionConfig.multi.id,
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

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.theme,
    required this.primary,
    required this.title,
    required this.monthly,
    required this.yearly,
    required this.highlighted,
    required this.compact,
  });

  final ThemeData theme;
  final Color primary;
  final String title;
  final double monthly;
  final double yearly;
  final bool highlighted;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: highlighted
            ? Border.all(color: primary.withValues(alpha: 0.45))
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${monthly.toStringAsFixed(2)} EUR${DiscPrestaSub.perMonth}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${yearly.toStringAsFixed(0)} EUR${DiscPrestaSub.perYear}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

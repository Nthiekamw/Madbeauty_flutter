import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/config/prestataire_subscription_config.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../../../services/stripe/stripe_service.dart';
import '../../../../../services/stripe/stripe_subscription_providers.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../../../../../shared/widgets/discovery/content/discovery_shimmer.dart';
import '../../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../providers/subscription/prestataire_subscription_provider.dart';
import '../../shared/prestataire_section_header.dart';

/// Aperçu des paliers d'abonnement dans « Mon compte ».
class PrestataireSubscriptionPlansSection extends ConsumerWidget {
  const PrestataireSubscriptionPlansSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!StripeService.isConfigured) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final serviceCountAsync = ref.watch(prestatairePublishedServiceCountProvider);
    final statusAsync = ref.watch(prestataireSubscriptionStatusProvider);

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrestataireSectionHeader(
            icon: Icons.workspace_premium_rounded,
            title: DiscPrestaSub.accountPlansTitle,
            subtitle: DiscPrestaSub.accountPlansHint,
            iconColor: primary,
          ),
          const SizedBox(height: 12),
          serviceCountAsync.when(
            loading: () => const DiscoveryInlineSkeleton(
              height: 72,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            error: (_, __) => DiscoverySectionError(
              message: DiscPrestaDash.loadErr,
              onRetry: () => ref.invalidate(
                prestatairePublishedServiceCountProvider,
              ),
            ),
            data: (serviceCount) {
              final currentTier =
                  PrestataireSubscriptionConfig.tierForServiceCount(
                serviceCount,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    DiscPrestaSub.serviceCount.replaceFirst(
                      '%s',
                      '$serviceCount',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _PlanTierRow(
                    theme: theme,
                    primary: primary,
                    title: DiscPrestaSub.tierSolo,
                    monthly: PrestataireSubscriptionConfig.solo.monthlyEur,
                    yearly: PrestataireSubscriptionConfig.solo.yearlyEur,
                    highlighted:
                        currentTier.id == PrestataireSubscriptionConfig.solo.id,
                  ),
                  const SizedBox(height: 8),
                  _PlanTierRow(
                    theme: theme,
                    primary: primary,
                    title: DiscPrestaSub.tierMulti,
                    monthly: PrestataireSubscriptionConfig.multi.monthlyEur,
                    yearly: PrestataireSubscriptionConfig.multi.yearlyEur,
                    highlighted: currentTier.id ==
                        PrestataireSubscriptionConfig.multi.id,
                  ),
                  const SizedBox(height: 14),
                  statusAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => _SubscribeCta(
                      theme: theme,
                      label: DiscPrestaSub.viewFullDetails,
                      onPressed: () => context.pushPrestataireSubscription(),
                    ),
                    data: (status) {
                      if (status.isActive) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  DiscPrestaSub.statusActive,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return _SubscribeCta(
                        theme: theme,
                        label: DiscPaymentMethods.subscriptionSubscribe,
                        onPressed: () => context.pushPrestataireSubscription(),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SubscribeCta extends StatelessWidget {
  const _SubscribeCta({
    required this.theme,
    required this.label,
    required this.onPressed,
  });

  final ThemeData theme;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.payment_rounded),
          label: Text(label),
        ),
        const SizedBox(height: 6),
        Text(
          DiscPrestaSub.heroBodyShort,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _PlanTierRow extends StatelessWidget {
  const _PlanTierRow({
    required this.theme,
    required this.primary,
    required this.title,
    required this.monthly,
    required this.yearly,
    required this.highlighted,
  });

  final ThemeData theme;
  final Color primary;
  final String title;
  final double monthly;
  final double yearly;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: highlighted
            ? Border.all(color: primary.withValues(alpha: 0.45), width: 1.5)
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
              ),
        color: highlighted
            ? primary.withValues(alpha: 0.06)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (highlighted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      DiscPrestaSub.accountPlansRecommended,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${monthly.toStringAsFixed(2)} €${DiscPrestaSub.perMonth}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                ),
                Text(
                  '${yearly.toStringAsFixed(0)} €${DiscPrestaSub.perYear}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

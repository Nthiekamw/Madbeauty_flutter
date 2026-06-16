import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/config/prestataire_subscription_config.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../../../services/stripe/stripe_service.dart';
import '../../../../../services/stripe/stripe_subscription_providers.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../../../../../shared/widgets/discovery/content/discovery_shimmer.dart';
import '../../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../providers/subscription/prestataire_subscription_provider.dart';
import 'prestataire_subscription_tier_cards.dart';
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
                  PrestataireSubscriptionTierCards(
                    currentTierId: currentTier.id,
                    compact: true,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/prestataire_subscription_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/discovery/discovery_screen_header.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../providers/prestataire_subscription_provider.dart';
import '../widgets/profile/subscription/prestataire_subscription_checkout_section.dart';

/// Grille d’abonnement + paiement Stripe Checkout.
class PrestataireSubscriptionScreen extends ConsumerWidget {
  const PrestataireSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final serviceCountAsync = ref.watch(prestatairePublishedServiceCountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(DiscPrestaSub.screenTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const DiscoveryScreenHeader(
            title: DiscPrestaSub.heroTitle,
            subtitle: DiscPrestaSub.heroBody,
          ),
          serviceCountAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                DiscPrestaDash.loadErr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            data: (serviceCount) {
              final currentTier =
                  PrestataireSubscriptionConfig.tierForServiceCount(
                serviceCount,
              );
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DiscoverySurfaceCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DiscPrestaSub.currentTier,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontFamily: AppFonts.body,
                              fontWeight: FontWeight.w700,
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DiscPrestaSub.serviceCount.replaceFirst(
                              '%s',
                              '$serviceCount',
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentTier.id == 'solo'
                                ? DiscPrestaSub.tierSolo
                                : DiscPrestaSub.tierMulti,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontFamily: AppFonts.display,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _TierCard(
                      theme: theme,
                      primary: primary,
                      title: DiscPrestaSub.tierSolo,
                      monthly: PrestataireSubscriptionConfig.solo.monthlyEur,
                      yearly: PrestataireSubscriptionConfig.solo.yearlyEur,
                      highlighted:
                          currentTier.id == PrestataireSubscriptionConfig.solo.id,
                    ),
                    const SizedBox(height: 12),
                    _TierCard(
                      theme: theme,
                      primary: primary,
                      title: DiscPrestaSub.tierMulti,
                      monthly: PrestataireSubscriptionConfig.multi.monthlyEur,
                      yearly: PrestataireSubscriptionConfig.multi.yearlyEur,
                      highlighted:
                          currentTier.id == PrestataireSubscriptionConfig.multi.id,
                    ),
                    const SizedBox(height: 20),
                    const PrestataireSubscriptionCheckoutSection(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
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
    return DiscoverySurfaceCard(
      padding: const EdgeInsets.all(18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: highlighted
              ? Border.all(color: primary.withValues(alpha: 0.5), width: 1.5)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              _PriceRow(
                label: DiscPrestaSub.monthly,
                value: '${monthly.toStringAsFixed(2)} €${DiscPrestaSub.perMonth}',
                theme: theme,
                primary: primary,
              ),
              const SizedBox(height: 8),
              _PriceRow(
                label: DiscPrestaSub.yearly,
                value: '${yearly.toStringAsFixed(0)} €${DiscPrestaSub.perYear}',
                theme: theme,
                primary: primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    required this.theme,
    required this.primary,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: primary,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_button.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../providers/subscription/prestataire_subscription_gate_provider.dart';

/// Affiche [child] ou un écran de blocage si l’abonnement pro est requis.
class PrestataireSubscriptionGate extends ConsumerWidget {
  const PrestataireSubscriptionGate({
    super.key,
    required this.child,
    this.requireSubscription = true,
    this.lockedMessage,
  });

  final Widget child;
  final bool requireSubscription;
  final String? lockedMessage;

  static const _urgent = AppColors.notificationDot;
  static const _urgentDeep = AppColors.errorLight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!requireSubscription) return child;

    final subscribed = ref.watch(prestataireHasActiveSubscriptionProvider);
    if (subscribed) return child;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _urgent.withValues(alpha: isDark ? 0.85 : 0.95),
                      _urgentDeep.withValues(alpha: 0.75),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _urgent.withValues(alpha: 0.35),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Icon(
                    Icons.lock_clock_rounded,
                    size: 40,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _urgent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _urgent.withValues(alpha: 0.55),
                  ),
                ),
                child: Text(
                  DiscPrestaSub.notVisibleBannerBadge,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _urgentDeep,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                DiscPrestaSub.featureLockedTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: _urgentDeep,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                lockedMessage ?? DiscPrestaSub.featureLockedBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              DiscoverySurfaceCard(
                padding: const EdgeInsets.all(16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _urgent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 22,
                          color: _urgent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            DiscPrestaSub.notVisibleGateHint,
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.35,
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                onPressed: () => context.pushPrestataireSubscription(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(DiscPrestaSub.notVisibleBannerCta),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

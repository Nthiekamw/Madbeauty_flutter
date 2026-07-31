import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/loyalty/loyalty_providers.dart';
import '../../../services/supabase/loyalty/loyalty_service.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/layout/profile_flow_scaffold.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/discovery/content/discovery_detail_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../shared/widgets/app/app_button.dart';

class LoyaltyScreen extends ConsumerWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final infoAsync = ref.watch(myLoyaltyInfoProvider);
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;
    final listPadding = useWeb
        ? const EdgeInsets.fromLTRB(20, 16, 20, 32)
        : const EdgeInsets.fromLTRB(20, 4, 20, 32);

    return ProfileFlowScaffold(
      title: DiscLoyalty.screenTitle,
      icon: Icons.stars_rounded,
      body: infoAsync.when(
        loading: () => const DiscoveryDetailSkeleton(),
        error: (_, __) => DiscoveryEmptyState(
          icon: Icons.cloud_off_outlined,
          title: CoreStrings.networkErrorTitle,
          body: DiscLoyalty.loadErr,
          iconColor: theme.colorScheme.error,
          actionLabel: DiscList.retry,
          onAction: () => ref.invalidate(myLoyaltyInfoProvider),
        ),
        data: (info) {
          if (info == null) {
            return DiscoveryEmptyState(
              icon: Icons.stars_outlined,
              title: DiscLoyalty.loadErr,
              body: DiscLoyalty.loadErr,
              actionLabel: DiscList.retry,
              onAction: () => ref.invalidate(myLoyaltyInfoProvider),
            );
          }
          return ListView(
            padding: listPadding,
            children: [
              _LoyaltyHero(theme: theme, info: info),
              const SizedBox(height: 18),
              _LoyaltyProgressCard(theme: theme, info: info),
              const SizedBox(height: 14),
              _LoyaltyHowCard(theme: theme),
              const SizedBox(height: 14),
              _LoyaltyBadgesCard(theme: theme, info: info),
              if (info.canRedeem) ...[
                const SizedBox(height: 18),
                _LoyaltyRedeemBanner(theme: theme, info: info),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _LoyaltyHero extends StatelessWidget {
  const _LoyaltyHero({required this.theme, required this.info});

  final ThemeData theme;
  final LoyaltyInfo info;

  @override
  Widget build(BuildContext context) {
    final gold = AppColors.brandGold;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gold.withValues(alpha: 0.22),
            theme.colorScheme.primary.withValues(alpha: 0.12),
          ],
        ),
        border: Border.all(color: gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: gold, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DiscLoyalty.heroTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DiscLoyalty.heroBody,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoyaltyProgressCard extends StatelessWidget {
  const _LoyaltyProgressCard({required this.theme, required this.info});

  final ThemeData theme;
  final LoyaltyInfo info;

  @override
  Widget build(BuildContext context) {
    final gold = AppColors.brandGold;
    final primary = theme.colorScheme.primary;

    return DiscoverySurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              DiscLoyalty.progressTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 168,
              height: 168,
              child: CustomPaint(
                painter: _LoyaltyRingPainter(
                  progress: info.progressFraction,
                  trackColor: theme.colorScheme.outline.withValues(alpha: 0.18),
                  progressColor: info.canRedeem ? gold : primary,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DiscLoyalty.pointsLabel(info.points),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DiscLoyalty.goalLabel(info.pointsPerReward),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DiscLoyalty.remaining(info.pointsRemaining),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: info.canRedeem
                    ? AppColors.brandGoldDark
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (info.rewardsRedeemed > 0) ...[
              const SizedBox(height: 8),
              Text(
                DiscLoyalty.rewardsUsed(info.rewardsRedeemed),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoyaltyRingPainter extends CustomPainter {
  _LoyaltyRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    const stroke = 12.0;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _LoyaltyRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}

class _LoyaltyHowCard extends StatelessWidget {
  const _LoyaltyHowCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return DiscoverySurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DiscLoyalty.howTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(DiscLoyalty.howStep1, style: _body(theme)),
            const SizedBox(height: 8),
            Text(DiscLoyalty.howStep2, style: _body(theme)),
            const SizedBox(height: 8),
            Text(DiscLoyalty.howStep3, style: _body(theme)),
            const SizedBox(height: 12),
            Text(
              DiscLoyalty.economicsHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle? _body(ThemeData theme) => theme.textTheme.bodyMedium?.copyWith(
        height: 1.4,
      );
}

class _LoyaltyBadgesCard extends StatelessWidget {
  const _LoyaltyBadgesCard({required this.theme, required this.info});

  final ThemeData theme;
  final LoyaltyInfo info;

  String _titleFor(String id) => switch (id) {
        'steps' => DiscLoyalty.badgeSteps,
        'loyal' => DiscLoyalty.badgeLoyal,
        'vip' => DiscLoyalty.badgeVip,
        'reward' => DiscLoyalty.badgeReward,
        _ => id,
      };

  IconData _iconFor(String id) => switch (id) {
        'steps' => Icons.directions_walk_rounded,
        'loyal' => Icons.favorite_rounded,
        'vip' => Icons.workspace_premium_rounded,
        'reward' => Icons.card_giftcard_rounded,
        _ => Icons.military_tech_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return DiscoverySurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DiscLoyalty.badgesTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 420;
                final children = info.badges.map((b) {
                  return _BadgeTile(
                    theme: theme,
                    title: _titleFor(b.id),
                    subtitle: DiscLoyalty.badgeThreshold(b.threshold),
                    icon: _iconFor(b.id),
                    unlocked: b.unlocked,
                  );
                }).toList();
                if (wide) {
                  return Row(
                    children: [
                      for (var i = 0; i < children.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(child: children[i]),
                      ],
                    ],
                  );
                }
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: children
                      .map(
                        (c) => SizedBox(
                          width: (constraints.maxWidth - 10) / 2,
                          child: c,
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.unlocked,
  });

  final ThemeData theme;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final accent = unlocked ? AppColors.brandGold : theme.colorScheme.outline;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: unlocked
            ? AppColors.brandGold.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: Border.all(
          color: accent.withValues(alpha: unlocked ? 0.35 : 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: unlocked ? AppColors.brandGoldDark : accent,
            size: 22,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: unlocked ? null : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoyaltyRedeemBanner extends StatelessWidget {
  const _LoyaltyRedeemBanner({required this.theme, required this.info});

  final ThemeData theme;
  final LoyaltyInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            AppColors.brandGold.withValues(alpha: 0.28),
            theme.colorScheme.primary.withValues(alpha: 0.14),
          ],
        ),
        border: Border.all(color: AppColors.brandGold.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            DiscLoyalty.redeemReadyTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DiscLoyalty.redeemReadyBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          AppButton(
            onPressed: () => context.goHome(),
            child: const Text(DiscLoyalty.redeemCta),
          ),
        ],
      ),
    );
  }
}

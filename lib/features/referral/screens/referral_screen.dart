import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/pricing_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../services/supabase/referral/referral_providers.dart';
import '../../../services/supabase/referral/referral_service.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_detail_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_constrained_body.dart';
import '../../../shared/widgets/discovery/discovery_feature_header.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../logic/referral_pending_apply.dart';
import '../logic/referral_share.dart';

class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen> {
  final _codeController = TextEditingController();
  bool _applying = false;
  bool _pendingTried = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryPendingCode());
  }

  Future<void> _tryPendingCode() async {
    if (_pendingTried || !mounted) return;
    _pendingTried = true;
    final result = await applyPendingReferralCode(ref);
    if (!mounted || result == null) return;
    if (result == ApplyReferralResult.success) {
      AppSnackBar.success(context, DiscReferral.referredWelcome);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _applyManualCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    final service = ref.read(referralServiceProvider);
    if (service == null) {
      AppSnackBar.error(context, DiscReferral.loadErr);
      return;
    }

    setState(() => _applying = true);
    try {
      final result = await service.applyReferralCode(code);
      if (!mounted) return;
      if (result == ApplyReferralResult.success) {
        AppSnackBar.success(context, DiscReferral.referredWelcome);
        _codeController.clear();
        ref.invalidate(myReferralInfoProvider);
      } else {
        AppSnackBar.error(context, messageForApplyResult(result));
      }
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final infoAsync = ref.watch(myReferralInfoProvider);

    return DiscoveryBrandScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const DiscoveryFeatureHeader(
            title: DiscReferral.screenTitle,
            icon: Icons.card_giftcard_rounded,
          ),
          Expanded(
            child: infoAsync.when(
              loading: () => const DiscoveryDetailSkeleton(),
              error: (_, __) => DiscoveryEmptyState(
                icon: Icons.cloud_off_outlined,
                title: CoreStrings.networkErrorTitle,
                body: DiscReferral.loadErr,
                iconColor: theme.colorScheme.error,
                actionLabel: DiscList.retry,
                onAction: () => ref.invalidate(myReferralInfoProvider),
              ),
              data: (info) {
                if (info == null) {
                  return Center(
                    child: Text(
                      DiscReferral.loadErr,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  );
                }
                return DiscoveryConstrainedBody(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                    children: [
                      _ReferralHeroBanner(theme: theme),
                      const SizedBox(height: 18),
                      _ReferralCodeCard(
                        theme: theme,
                        code: info.code,
                        onCopy: () async {
                          await copyReferralCode(info.code);
                          if (context.mounted) {
                            AppSnackBar.success(
                              context,
                              DiscReferral.copied,
                            );
                          }
                        },
                        onShare: () => shareReferralInvite(info.code),
                      ),
                      const SizedBox(height: 14),
                      _ReferralRewardsCard(theme: theme, info: info),
                      const SizedBox(height: 14),
                      _ReferralStatsCard(
                        theme: theme,
                        count: info.invitationsCount,
                      ),
                      if (!info.hasReferrer) ...[
                        const SizedBox(height: 22),
                        _ReferralEnterCodeSection(
                          theme: theme,
                          controller: _codeController,
                          applying: _applying,
                          onApply: _applyManualCode,
                        ),
                      ] else ...[
                        const SizedBox(height: 18),
                        _ReferralAlreadyReferredCard(theme: theme),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralHeroBanner extends StatelessWidget {
  const _ReferralHeroBanner({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: 0.14),
            Color.lerp(primary, secondary, 0.35)!.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(color: primary.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.redeem_rounded,
                  color: primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DiscReferral.heroTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DiscReferral.heroBody,
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
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _BenefitChip(
                icon: Icons.percent_rounded,
                label: DiscReferral.benefitFriendDiscount(
                  PricingConfig.referralBookingDiscountPercent,
                ),
                color: primary,
              ),
              const _BenefitChip(
                icon: Icons.military_tech_rounded,
                label: DiscReferral.benefitAmbassadorMilestone,
                color: AppColors.ambassador,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _ReferralCodeCard extends StatelessWidget {
  const _ReferralCodeCard({
    required this.theme,
    required this.code,
    required this.onCopy,
    required this.onShare,
  });

  final ThemeData theme;
  final String code;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.all(18),
      includeHorizontalMargin: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.qr_code_2_rounded, size: 20, color: primary),
              const SizedBox(width: 8),
              Text(
                DiscReferral.yourCode,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  primary.withValues(alpha: 0.08),
                  theme.colorScheme.secondary.withValues(alpha: 0.06),
                ],
              ),
              border: Border.all(color: primary.withValues(alpha: 0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              child: SelectableText(
                code,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _ReferralActionButton(
            outlined: true,
            icon: Icons.copy_rounded,
            label: DiscReferral.copyCode,
            onPressed: onCopy,
          ),
          const SizedBox(height: 10),
          _ReferralActionButton(
            outlined: false,
            icon: Icons.share_rounded,
            label: DiscReferral.shareInvite,
            onPressed: onShare,
          ),
        ],
      ),
    );
  }
}

class _ReferralRewardsCard extends StatelessWidget {
  const _ReferralRewardsCard({required this.theme, required this.info});

  final ThemeData theme;
  final ReferralInfo info;

  @override
  Widget build(BuildContext context) {
    final accent =
        info.isAmbassador ? AppColors.ambassador : theme.colorScheme.primary;

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.all(18),
      includeHorizontalMargin: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  info.isAmbassador
                      ? Icons.military_tech_rounded
                      : Icons.emoji_events_outlined,
                  color: accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  DiscReferral.rewardsTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (info.isAmbassador) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.ambassadorBg10,
                    AppColors.ambassador.withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.ambassadorBorder25),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.military_tech_rounded,
                    color: AppColors.ambassador,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      DiscReferral.ambassadorBadge,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.ambassadorMid,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            info.isAmbassador
                ? DiscReferral.ambassadorUnlocked
                : info.rewardMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (!info.isAmbassador && info.nextMilestone != null) ...[
            const SizedBox(height: 16),
            _AmbassadorMilestoneTrack(
              theme: theme,
              current: info.invitationsCount,
              target: 3,
              remainingLabel: DiscReferral.invitesUntilAmbassador(
                info.nextMilestone!,
              ),
            ),
          ],
          if (info.discount?.available == true &&
              (info.discount?.percent ?? 0) > 0) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.ambassadorBg10,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.ambassador.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_offer_outlined,
                        size: 18,
                        color: AppColors.ambassadorMid,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          DiscReferral.discountActiveTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.ambassadorMid,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    info.discount!.label.isNotEmpty
                        ? info.discount!.label
                        : DiscReferral.discountActiveBody(
                            info.discount!.percent,
                          ),
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DiscReferral.discountUsedHint,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AmbassadorMilestoneTrack extends StatelessWidget {
  const _AmbassadorMilestoneTrack({
    required this.theme,
    required this.current,
    required this.target,
    required this.remainingLabel,
  });

  final ThemeData theme;
  final int current;
  final int target;
  final String remainingLabel;

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    final progress = (current / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < target; i++) ...[
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: i < current
                          ? primary
                          : theme.colorScheme.outline.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              _MilestoneDot(
                index: i + 1,
                filled: i < current,
                active: i == current,
                color: primary,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          remainingLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _MilestoneDot extends StatelessWidget {
  const _MilestoneDot({
    required this.index,
    required this.filled,
    required this.active,
    required this.color,
  });

  final int index;
  final bool filled;
  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: active ? 34 : 30,
          height: active ? 34 : 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? color
                : theme.colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: filled || active
                  ? color
                  : theme.colorScheme.outline.withValues(alpha: 0.25),
              width: active ? 2 : 1.5,
            ),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: filled
                ? const Icon(Icons.check_rounded, size: 16, color: AppColors.white)
                : Text(
                    '$index',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: active ? color : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ReferralStatsCard extends StatelessWidget {
  const _ReferralStatsCard({required this.theme, required this.count});

  final ThemeData theme;
  final int count;

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      includeHorizontalMargin: false,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.people_alt_rounded,
              color: primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DiscReferral.statInvites,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w900,
                color: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralEnterCodeSection extends StatelessWidget {
  const _ReferralEnterCodeSection({
    required this.theme,
    required this.controller,
    required this.applying,
    required this.onApply,
  });

  final ThemeData theme;
  final TextEditingController controller;
  final bool applying;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return DiscoverySurfaceCard(
      padding: const EdgeInsets.all(18),
      includeHorizontalMargin: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.vpn_key_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DiscReferral.enterCodeTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(12),
            ],
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: DiscReferral.enterCodeHint,
              hintStyle: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                letterSpacing: 1,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.65),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.55),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: applying ? null : onApply,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: applying
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      DiscReferral.applyCode,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralAlreadyReferredCard extends StatelessWidget {
  const _ReferralAlreadyReferredCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.all(16),
      includeHorizontalMargin: false,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_rounded, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              DiscReferral.alreadyReferred,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralActionButton extends StatelessWidget {
  const _ReferralActionButton({
    required this.outlined,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final bool outlined;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  static const _height = 48.0;
  static const _radius = 14.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      fontFamily: AppFonts.body,
      fontWeight: FontWeight.w700,
      fontSize: 14.5,
    );
    final labelWidget = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: labelStyle,
    );

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: _height,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            side: BorderSide(color: primary.withValues(alpha: 0.4)),
          ),
          icon: Icon(icon, size: 20, color: primary),
          label: labelWidget,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: _height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          gradient: LinearGradient(
            colors: [
              primary,
              Color.lerp(primary, theme.colorScheme.secondary, 0.4)!,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(_radius),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: AppColors.white),
                const SizedBox(width: 8),
                DefaultTextStyle(
                  style: labelStyle!.copyWith(color: AppColors.white),
                  child: labelWidget,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

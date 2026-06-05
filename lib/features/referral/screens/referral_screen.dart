import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../services/supabase/referral/referral_providers.dart';
import '../../../services/supabase/referral/referral_service.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Text(
                  DiscReferral.loadErr,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
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
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      Text(
                        DiscReferral.heroTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DiscReferral.heroBody,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      DiscoverySurfaceCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            Text(
                              DiscReferral.yourCode,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              info.code,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontFamily: AppFonts.display,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      await copyReferralCode(info.code);
                                      if (context.mounted) {
                                        AppSnackBar.success(
                                          context,
                                          DiscReferral.copied,
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.copy_rounded),
                                    label: const Text(DiscReferral.copyCode),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () =>
                                        shareReferralInvite(info.code),
                                    icon: const Icon(Icons.share_rounded),
                                    label: const Text(DiscReferral.shareInvite),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      DiscoverySurfaceCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DiscReferral.rewardsTitle,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (info.isAmbassador)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.military_tech_rounded,
                                    color: AppColors.ambassador,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      DiscReferral.ambassadorBadge,
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ambassadorMid,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 8),
                            Text(
                              info.isAmbassador
                                  ? DiscReferral.ambassadorUnlocked
                                  : info.rewardMessage,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.4,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (!info.isAmbassador &&
                                info.nextMilestone != null) ...[
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: info.invitationsCount / 3,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                DiscReferral.invitesUntilAmbassador(
                                  info.nextMilestone!,
                                ),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            if (info.discount?.available == true &&
                                (info.discount?.percent ?? 0) > 0) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.ambassadorBg10,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DiscReferral.discountActiveTitle,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.ambassadorMid,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      info.discount!.label.isNotEmpty
                                          ? info.discount!.label
                                          : DiscReferral.discountActiveBody(
                                              info.discount!.percent,
                                            ),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(height: 1.35),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DiscReferral.discountUsedHint,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      DiscoverySurfaceCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                DiscReferral.statInvites,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              '${info.invitationsCount}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!info.hasReferrer) ...[
                        const SizedBox(height: 24),
                        Text(
                          DiscReferral.enterCodeTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            hintText: DiscReferral.enterCodeHint,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _applying ? null : _applyManualCode,
                          child: _applying
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(DiscReferral.applyCode),
                        ),
                      ] else ...[
                        const SizedBox(height: 20),
                        DiscoverySurfaceCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  DiscReferral.alreadyReferred,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
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


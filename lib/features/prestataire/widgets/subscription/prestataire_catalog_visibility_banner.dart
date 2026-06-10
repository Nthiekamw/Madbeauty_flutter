import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../providers/subscription/prestataire_subscription_gate_provider.dart';
import '../profile/overview/layout/prestataire_profile_insets.dart';
import '../shared/prestataire_section_header.dart';

/// Bandeau urgent : profil prêt mais invisible catalogue (pas d’abonnement).
class PrestataireCatalogVisibilityBanner extends ConsumerWidget {
  const PrestataireCatalogVisibilityBanner({super.key});

  static const _urgent = AppColors.notificationDot;
  static const _urgentDeep = AppColors.errorLight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needsSub = ref.watch(prestataireNeedsSubscriptionForCatalogProvider);
    if (!needsSub) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: PrestataireProfileInsets.page(context).copyWith(
        top: 12,
        bottom: 4,
      ),
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 0,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.pushPrestataireSubscription(),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  _urgent.withValues(alpha: isDark ? 0.28 : 0.2),
                  _urgentDeep.withValues(alpha: isDark ? 0.18 : 0.1),
                ],
              ),
              border: Border.all(
                color: _urgent.withValues(alpha: isDark ? 0.75 : 0.65),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _urgent.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 5,
                    color: _urgent,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.priority_high_rounded,
                                size: 18,
                                color: _urgentDeep,
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _urgent.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _urgent.withValues(alpha: 0.7),
                                  ),
                                ),
                                child: Text(
                                  DiscPrestaSub.notVisibleBannerBadge,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontFamily: AppFonts.body,
                                    fontWeight: FontWeight.w800,
                                    color: _urgentDeep,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          PrestataireSectionHeader(
                            icon: Icons.visibility_off_rounded,
                            title: DiscPrestaSub.notVisibleBannerTitle,
                            subtitle: DiscPrestaSub.notVisibleBannerBody,
                            iconColor: _urgentDeep,
                          ),
                          const SizedBox(height: 14),
                          FilledButton.icon(
                            onPressed: () =>
                                context.pushPrestataireSubscription(),
                            style: FilledButton.styleFrom(
                              backgroundColor: _urgent,
                              foregroundColor: AppColors.white,
                              elevation: 2,
                              shadowColor: _urgent.withValues(alpha: 0.45),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.bolt_rounded,
                              size: 20,
                            ),
                            label: Text(
                              DiscPrestaSub.notVisibleBannerCta,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

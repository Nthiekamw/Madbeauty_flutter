import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_colors.dart';
import '../logic/pwa_install_actions.dart';
import '../providers/pwa_install_provider.dart';

/// Bandeau d’installation PWA (Chrome Android / Safari iOS).
class PwaInstallBanner extends ConsumerWidget {
  const PwaInstallBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pwaInstallProvider);
    if (!state.bannerVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: AppColors.brandBrown.withValues(alpha: 0.96),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.install_mobile_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DiscPwa.installBannerTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DiscPwa.installBannerBody,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => handlePwaInstallTap(context, ref, state),
                          child: Text(
                            state.showIosInstructions
                                ? DiscPwa.installBannerIosAction
                                : DiscPwa.installBannerAction,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              ref.read(pwaInstallProvider.notifier).dismiss(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withValues(alpha: 0.92),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(DiscPwa.installBannerDismiss),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.close_rounded,
                  color: Colors.white.withValues(alpha: 0.85),
                  size: 20,
                ),
                onPressed: () =>
                    ref.read(pwaInstallProvider.notifier).dismiss(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

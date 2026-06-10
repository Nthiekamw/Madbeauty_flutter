import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../agenda/prestataire_availability_badge.dart';
import '../media/prestataire_realisation_carousel_scope.dart';

/// Hero photo + actions (partager, signaler, favori).
class PrestataireDetailHero extends ConsumerWidget {
  const PrestataireDetailHero({
    super.key,
    required this.prestataireId,
    required this.displayTitle,
    this.avatarUrl,
    required this.isOwnProfile,
    required this.onShare,
    this.onReport,
  });

  final String prestataireId;
  final String displayTitle;
  final String? avatarUrl;
  final bool isOwnProfile;
  final VoidCallback onShare;
  final VoidCallback? onReport;

  static const double expandedHeight = 280;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      stretch: true,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: AppColors.transparent,
      actions: [
        if (onReport != null)
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: DiscReport.action,
            onPressed: onReport,
          ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          tooltip: DiscPrestaDetail.shareTooltip,
          onPressed: onShare,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return PrestataireRealisationCarouselScope(
                  prestataireId: prestataireId,
                  height: constraints.maxHeight,
                  fallbackDisplayName: displayTitle,
                  fallbackAvatarUrl: avatarUrl,
                );
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    AppColors.scrimDark25,
                    AppColors.transparent,
                    theme.colorScheme.surface.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: PrestataireAvailabilityBadge(
                prestataireId: prestataireId,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

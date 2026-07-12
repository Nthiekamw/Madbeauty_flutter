import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/models/domain/user/prestataire_profile.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/utils/text_normalizer.dart';
import '../../../../../shared/widgets/app/app_avatar.dart';
import '../../agenda/prestataire_availability_badge.dart';
import '../media/prestataire_realisation_carousel_scope.dart';

/// En-tête fiche publique : couverture réalisations + identité centrée.
class PrestataireDetailHero extends ConsumerWidget {
  const PrestataireDetailHero({
    super.key,
    required this.profile,
    required this.displayTitle,
    this.avatarUrl,
    required this.onShare,
    this.onReport,
  });

  final PrestataireProfile profile;
  final String displayTitle;
  final String? avatarUrl;
  final VoidCallback onShare;
  final VoidCallback? onReport;

  static const _avatarOverlap = 36.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final r = DiscoveryResponsive.of(context);
    final pad = r.pageHorizontalPadding(flow: true);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final salon = normalizeSingleLineText(profile.nomSalon);
    final showSalon = salon.isNotEmpty && salon != displayTitle;
    final ville = profile.ville?.trim() ?? '';
    final cp = profile.codePostal?.trim() ?? '';
    final locationLine = [
      if (ville.isNotEmpty) ville,
      if (cp.isNotEmpty) cp,
    ].join(' · ');

    final coverHeight = r.useWebSiteLayout
        ? (r.isDesktop ? 300.0 : (r.isWide ? 272.0 : 248.0))
        : r.isTablet
            ? 228.0
            : (r.isCompact ? 172.0 : 204.0);
    final avatarRadius = r.isTablet ? 44.0 : (r.isCompact ? 34.0 : 40.0);
    final identityBlock = avatarRadius * 2 +
        8 +
        38 +
        (showSalon ? 16.0 : 0) +
        (locationLine.isNotEmpty ? 28.0 : 0) +
        22;
    final expandedHeight =
        coverHeight + identityBlock - _avatarOverlap + kToolbarHeight - 18;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      stretch: true,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: AppColors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      title: Text(
        displayTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          fontFamily: AppFonts.display,
          fontWeight: FontWeight.w800,
        ),
      ),
      leading: Padding(
        padding: EdgeInsets.only(left: pad - 4),
        child: _HeroIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.popOrGoHome(),
          onCover: true,
        ),
      ),
      actions: [
        if (onReport != null)
          _HeroIconButton(
            icon: Icons.flag_outlined,
            tooltip: DiscReport.action,
            onPressed: onReport!,
            onCover: true,
          ),
        _HeroIconButton(
          icon: Icons.share_outlined,
          tooltip: DiscPrestaDetail.shareTooltip,
          onPressed: onShare,
          onCover: true,
        ),
        SizedBox(width: pad - 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                SizedBox(
                  height: coverHeight,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PrestataireRealisationCarouselScope(
                        prestataireId: profile.id,
                        height: coverHeight,
                        borderRadius: BorderRadius.zero,
                        fallbackDisplayName: displayTitle,
                        fallbackAvatarUrl: avatarUrl,
                        playVideos: false,
                        imagesOnly: true,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black
                                  .withValues(alpha: isDark ? 0.35 : 0.18),
                              Colors.black
                                  .withValues(alpha: isDark ? 0.55 : 0.42),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ColoredBox(color: theme.colorScheme.surface),
                ),
              ],
            ),
            Positioned(
              left: pad,
              right: pad,
              top: coverHeight - _avatarOverlap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ProfileAvatarFrame(
                    avatarUrl: avatarUrl,
                    displayTitle: displayTitle,
                    radius: avatarRadius,
                    isVerified: profile.isVerified,
                    primary: primary,
                  ),
                  SizedBox(height: r.isCompact ? 8 : 10),
                  Text(
                    displayTitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w900,
                      fontSize:
                          r.isTablet ? 22 : (r.isCompact ? 17 : 19),
                      letterSpacing: -0.35,
                      height: 1.15,
                    ),
                  ),
                  if (showSalon) ...[
                    const SizedBox(height: 3),
                    Text(
                      salon,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (locationLine.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _LocationChip(label: locationLine),
                  ],
                  const SizedBox(height: 6),
                  PrestataireAvailabilityBadge(
                    prestataireId: profile.id,
                    compact: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatarFrame extends StatelessWidget {
  const _ProfileAvatarFrame({
    required this.avatarUrl,
    required this.displayTitle,
    required this.radius,
    required this.isVerified,
    required this.primary,
  });

  final String? avatarUrl;
  final String displayTitle;
  final double radius;
  final bool isVerified;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.brandBrown.withValues(alpha: 0.14),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: AppAvatar(
            imageUrl: avatarUrl,
            displayName: displayTitle,
            radius: radius,
          ),
        ),
        if (isVerified)
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.surface, width: 2),
              ),
              child: Icon(
                Icons.verified_rounded,
                size: radius * 0.38,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
      ],
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : AppColors.filterChipInactive,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.onCover = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool onCover;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const size = 38.0;

    return Center(
      child: Material(
        color: onCover
            ? Colors.black.withValues(alpha: 0.38)
            : theme.colorScheme.surface.withValues(alpha: 0.95),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 20,
            color: onCover ? AppColors.white : theme.colorScheme.onSurface,
          ),
          style: IconButton.styleFrom(
            minimumSize: const Size(size, size),
            maximumSize: const Size(size, size),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

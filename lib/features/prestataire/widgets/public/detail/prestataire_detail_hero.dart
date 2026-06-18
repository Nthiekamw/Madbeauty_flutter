import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/models/domain/user/prestataire_profile.dart';
import '../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/theme/discovery_styles.dart';
import '../../../../../shared/utils/text_normalizer.dart';
import '../../../../../shared/widgets/app/app_avatar.dart';
import '../../agenda/prestataire_availability_badge.dart';
import 'sections/prestataire_detail_surface.dart';

/// En-tête fiche publique : photo de profil à gauche, identité à droite.
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final r = DiscoveryResponsive.of(context);
    final pad = r.horizontalPadding;
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final salon = normalizeSingleLineText(profile.nomSalon);
    final showSalon = salon.isNotEmpty && salon != displayTitle;
    final ville = profile.ville?.trim() ?? '';
    final cp = profile.codePostal?.trim() ?? '';
    final hasLocation = ville.isNotEmpty || cp.isNotEmpty;

    final tagline = _heroTagline(profile);
    final showTagline = tagline != null && !r.isCompact;
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.35);
    final avatarRadius = r.isTablet ? 40.0 : (r.isCompact ? 30.0 : 36.0);
    final avatarOuter = (avatarRadius + 5) * 2;
    final cardHeight = _resolveCardHeight(
      r: r,
      avatarOuter: avatarOuter,
      showSalon: showSalon,
      hasVille: ville.isNotEmpty,
      hasCp: cp.isNotEmpty,
      showTagline: showTagline,
      textScale: textScale,
    );

    return SliverAppBar(
      expandedHeight: cardHeight + kToolbarHeight + 16,
      pinned: true,
      stretch: false,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: AppColors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: Padding(
        padding: EdgeInsets.only(left: pad - 4),
        child: _HeroIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      actions: [
        if (onReport != null)
          _HeroIconButton(
            icon: Icons.flag_outlined,
            tooltip: DiscReport.action,
            onPressed: onReport!,
          ),
        _HeroIconButton(
          icon: Icons.share_outlined,
          tooltip: DiscPrestaDetail.shareTooltip,
          onPressed: onShare,
        ),
        SizedBox(width: pad - 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Padding(
          padding: EdgeInsets.fromLTRB(pad, kToolbarHeight + 8, pad, 12),
          child: PrestataireDetailSurface.cardMaterial(
            theme: theme,
            padding: EdgeInsets.all(r.isCompact ? 12 : 14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: DiscoveryStyles.cardBorderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          primary.withValues(alpha: 0.12),
                          theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.35),
                        ]
                      : [
                          AppColors.brandGoldLight.withValues(alpha: 0.22),
                          AppColors.cardSurfaceLight,
                        ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(r.isCompact ? 10 : 12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final badgeGap = r.isCompact ? 6.0 : 10.0;
                    final content = Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ProfileAvatarFrame(
                              avatarUrl: avatarUrl,
                              displayTitle: displayTitle,
                              radius: avatarRadius,
                              isVerified: profile.isVerified,
                              primary: primary,
                            ),
                            SizedBox(width: r.isCompact ? 12 : 14),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayTitle,
                                    maxLines: r.isCompact ? 1 : 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontFamily: AppFonts.display,
                                      fontWeight: FontWeight.w900,
                                      fontSize: r.isTablet
                                          ? 20
                                          : (r.isCompact ? 16 : 17),
                                      letterSpacing: -0.35,
                                      height: 1.15,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  if (showSalon) ...[
                                    SizedBox(height: r.isCompact ? 2 : 3),
                                    Text(
                                      salon,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w700,
                                        fontSize: r.isCompact ? 11 : 12,
                                      ),
                                    ),
                                  ],
                                  if (hasLocation) ...[
                                    SizedBox(height: r.isCompact ? 3 : 5),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 1),
                                          child: Icon(
                                            Icons.location_on_outlined,
                                            size: r.isCompact ? 13 : 14,
                                            color:
                                                theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (ville.isNotEmpty)
                                                Text(
                                                  ville,
                                                  maxLines: r.isCompact ? 1 : 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: theme.textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant,
                                                    fontSize:
                                                        r.isCompact ? 11 : 12,
                                                    height: 1.2,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              if (cp.isNotEmpty) ...[
                                                if (ville.isNotEmpty)
                                                  const SizedBox(height: 2),
                                                Text(
                                                  cp,
                                                  maxLines: 1,
                                                  style: theme.textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant,
                                                    fontSize:
                                                        r.isCompact ? 11 : 12,
                                                    height: 1.2,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 0.2,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (showTagline) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      tagline,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.78),
                                        height: 1.35,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: badgeGap),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            PrestataireAvailabilityBadge(
                              prestataireId: profile.id,
                              compact: true,
                            ),
                            if (profile.isVerified && r.isTablet)
                              _VerifiedChip(primary: primary),
                          ],
                        ),
                      ],
                    );

                    if (!constraints.hasBoundedHeight) return content;

                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                        child: content,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _heroTagline(PrestataireProfile profile) {
    final description = normalizeSingleLineText(profile.description);
    if (description.isNotEmpty) return description;
    final bio = normalizeSingleLineText(profile.bio);
    if (bio.isNotEmpty) return bio;
    return null;
  }

  double _resolveCardHeight({
    required DiscoveryResponsive r,
    required double avatarOuter,
    required bool showSalon,
    required bool hasVille,
    required bool hasCp,
    required bool showTagline,
    double textScale = 1,
  }) {
    if (r.isTablet) return 168 * textScale;

    var identityBlock = (r.isCompact ? 20.0 : 42.0) * textScale;
    if (showSalon) identityBlock += (r.isCompact ? 14 : 18) * textScale;
    if (hasVille) identityBlock += (r.isCompact ? 14 : 22) * textScale;
    if (hasCp) identityBlock += 14 * textScale;
    if (showTagline) identityBlock += 34 * textScale;

    final rowHeight =
        avatarOuter > identityBlock ? avatarOuter : identityBlock;
    final badgesRow = 32.0 * textScale;
    final gap = r.isCompact ? 6.0 : 10.0;
    final surfacePadding = (r.isCompact ? 12.0 : 14.0) * 2;
    final gradientPadding = (r.isCompact ? 10.0 : 12.0) * 2;
    const safety = 12.0;
    return rowHeight + badgesRow + gap + surfacePadding + gradientPadding + safety;
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
    final outer = radius + 5;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: outer * 2,
          height: outer * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.brandGold,
                primary.withValues(alpha: 0.85),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandBrown.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Material(
              color: theme.colorScheme.surface,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: AppAvatar(
                imageUrl: avatarUrl,
                displayName: displayTitle,
                radius: radius,
              ),
            ),
          ),
        ),
        if (isVerified)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: primary.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.12),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.verified_rounded,
                size: radius * 0.42,
                color: primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_outlined, size: 13, color: primary),
          const SizedBox(width: 4),
          Text(
            DiscPrestaDetail.badgeVerified,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 10,
              color: primary,
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
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const size = 36.0;

    return Center(
      child: Material(
        color: theme.colorScheme.surface.withValues(alpha: 0.92),
        elevation: 1,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          style: IconButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface,
            minimumSize: const Size(size, size),
            maximumSize: const Size(size, size),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

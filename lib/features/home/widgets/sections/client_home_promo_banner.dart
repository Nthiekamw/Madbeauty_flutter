import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/discovery_promo_images.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_network_image.dart';

class _HomePromoMosaicTile {
  const _HomePromoMosaicTile({
    required this.url,
    required this.icon,
    this.alignment = Alignment.center,
  });

  final String url;
  final IconData icon;
  final Alignment alignment;
}

/// URLs vérifiées ([DiscoveryPromoImages]).
const _kHomePromoMosaicTiles = [
  _HomePromoMosaicTile(
    url: DiscoveryPromoImages.barberHome,
    icon: Icons.content_cut_rounded,
    alignment: Alignment(-0.15, 0),
  ),
  _HomePromoMosaicTile(
    url: DiscoveryPromoImages.makeupHome,
    icon: Icons.face_retouching_natural_rounded,
    alignment: Alignment(0, -0.1),
  ),
  _HomePromoMosaicTile(
    url: DiscoveryPromoImages.manicureHome,
    icon: Icons.back_hand_outlined,
    alignment: Alignment(0.1, 0),
  ),
  _HomePromoMosaicTile(
    url: DiscoveryPromoImages.hairSalonHome,
    icon: Icons.face_3_rounded,
    alignment: Alignment(0, 0),
  ),
  _HomePromoMosaicTile(
    url: DiscoveryPromoImages.spaHome,
    icon: Icons.spa_rounded,
    alignment: Alignment(0, 0.1),
  ),
  _HomePromoMosaicTile(
    url: DiscoveryPromoImages.nailTechHome,
    icon: Icons.brush_rounded,
    alignment: Alignment(0.1, 0),
  ),
];

const _kPlantAccentUrl = DiscoveryPromoImages.plantAccentHome;

/// Bannière hero accueil : texte à gauche + mosaïque inclinée à droite.
class ClientHomePromoBanner extends StatelessWidget {
  const ClientHomePromoBanner({super.key});

  static const _bannerSurfaceLight = Color(0xFFF9F7F2);
  static const _titleDark = Color(0xFF1A1A1A);
  static const _accentBrown = Color(0xFFA67147);
  static const _bannerRadius = 16.0;
  static const _mosaicGap = 3.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final layout = DiscoveryResponsive.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final outerMargin = layout.homePromoBannerOuterMargin;
    final bannerWidth = screenWidth - outerMargin * 2;
    final dims = layout.homePromoBannerDimensions(
      bannerWidth,
      horizontalPadding: 0,
    );

    return SizedBox(
      height: dims.height,
      child: Center(
        child: Material(
          color: AppColors.transparent,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(_bannerRadius),
          elevation: isDark ? 0 : 2,
          shadowColor: AppColors.black.withValues(alpha: 0.08),
          child: InkWell(
            borderRadius: BorderRadius.circular(_bannerRadius),
            onTap: () => context.goClientSearch(),
            child: Ink(
              width: dims.width,
              height: dims.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_bannerRadius),
                color: isDark
                    ? AppColors.darkSurfaceContainer
                    : _bannerSurfaceLight,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_bannerRadius),
                child: _HomePromoBannerHorizontalLayout(
                  width: dims.width,
                  height: dims.height,
                  layout: layout,
                  isDark: isDark,
                  gap: _mosaicGap,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Layout horizontal identique à la maquette (texte gauche, photos droite).
class _HomePromoBannerHorizontalLayout extends StatelessWidget {
  const _HomePromoBannerHorizontalLayout({
    required this.width,
    required this.height,
    required this.layout,
    required this.isDark,
    required this.gap,
  });

  final double width;
  final double height;
  final DiscoveryResponsive layout;
  final bool isDark;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final copyFraction = layout.isCompact ? 0.52 : 0.46;
    final mosaicLeft = width * (copyFraction - 0.06);
    final copyWidth = width * copyFraction;
    final diagonalInset = height * 0.08;
    final mosaicSkew = layout.isCompact ? 0.09 : 0.11;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: isDark
              ? AppColors.darkSurfaceContainer
              : ClientHomePromoBanner._bannerSurfaceLight,
        ),
        Positioned(
          left: mosaicLeft,
          top: 0,
          right: 0,
          bottom: 0,
          child: ClipPath(
            clipper: _DiagonalPanelClipper(bottomInset: diagonalInset),
            child: _HomePromoMosaicGrid(
              tiles: _kHomePromoMosaicTiles,
              isDark: isDark,
              gap: gap,
              skewFactor: mosaicSkew,
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: copyWidth,
          child: _HomePromoBannerCopy(
            layout: layout,
            isDark: isDark,
            copyWidth: copyWidth,
          ),
        ),
      ],
    );
  }
}

class _HomePromoBannerCopy extends StatelessWidget {
  const _HomePromoBannerCopy({
    required this.layout,
    required this.isDark,
    required this.copyWidth,
  });

  final DiscoveryResponsive layout;
  final bool isDark;
  final double copyWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typo = _PromoCopyTypography.forZone(
      copyWidth: copyWidth,
      screenWidth: layout.width,
    );

    final leadColor =
        isDark ? AppColors.darkOnSurface : ClientHomePromoBanner._titleDark;
    final accentColor = isDark
        ? AppColors.brandBrownDark
        : ClientHomePromoBanner._accentBrown;
    final subColor = isDark
        ? AppColors.darkOnSurfaceVariant
        : const Color(0xFF4A4A4A);
    final ctaBg = isDark
        ? AppColors.brandBrownMid
        : ClientHomePromoBanner._accentBrown;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: typo.horizontalPad - 10,
          bottom: 0,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Opacity(
              opacity: isDark ? 0.2 : 0.45,
              child: SizedBox(
                width: typo.plantSize,
                height: typo.plantSize,
                child: AppNetworkImage(
                  url: _kPlantAccentUrl,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomLeft,
                  error: Icon(
                    Icons.eco_outlined,
                    size: typo.plantSize * 0.55,
                    color: const Color(0xFF6B8F5E).withValues(alpha: 0.35),
                  ),
                  placeholder: const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            typo.horizontalPad,
            typo.verticalPad,
            6,
            typo.verticalPad,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    height: 1.16,
                    fontSize: typo.titleSize,
                    color: leadColor,
                    letterSpacing: -0.2,
                  ),
                  children: [
                    TextSpan(text: '${DiscHome.heroBannerLead}\n'),
                    TextSpan(
                      text: DiscHome.heroBannerAccent,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w800,
                        fontSize: typo.accentSize,
                        color: accentColor,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: typo.gapAfterTitle),
              Text(
                DiscHome.heroBannerSub,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w400,
                  fontSize: typo.subSize,
                  height: 1.32,
                  color: subColor,
                ),
                maxLines: typo.subMaxLines,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: typo.gapBeforeCta),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: ctaBg,
                  borderRadius: BorderRadius.circular(typo.ctaRadius),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: typo.ctaHPadding,
                    vertical: typo.ctaVPadding,
                  ),
                  child: Text(
                    DiscHome.heroBannerCta,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      fontSize: typo.ctaSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Typo bannière promo : échelle fluide selon la largeur écran et zone texte.
class _PromoCopyTypography {
  const _PromoCopyTypography({
    required this.titleSize,
    required this.accentSize,
    required this.subSize,
    required this.ctaSize,
    required this.horizontalPad,
    required this.verticalPad,
    required this.ctaHPadding,
    required this.ctaVPadding,
    required this.ctaRadius,
    required this.plantSize,
    required this.subMaxLines,
    required this.gapAfterTitle,
    required this.gapBeforeCta,
  });

  final double titleSize;
  final double accentSize;
  final double subSize;
  final double ctaSize;
  final double horizontalPad;
  final double verticalPad;
  final double ctaHPadding;
  final double ctaVPadding;
  final double ctaRadius;
  final double plantSize;
  final int subMaxLines;
  final double gapAfterTitle;
  final double gapBeforeCta;

  factory _PromoCopyTypography.forZone({
    required double copyWidth,
    required double screenWidth,
  }) {
    final pad = screenWidth < 360
        ? 10.0
        : screenWidth < 420
            ? 12.0
            : screenWidth < 600
                ? 14.0
                : screenWidth < 900
                    ? 22.0
                    : 28.0;
    final innerWidth = (copyWidth - pad - 6).clamp(96.0, 520.0);

    var titleSize = (innerWidth * 0.085).clamp(11.0, 26.0);
    if (screenWidth < 340) {
      titleSize = titleSize.clamp(11.0, 12.0);
    } else if (screenWidth < 380) {
      titleSize = titleSize.clamp(11.0, 12.5);
    } else if (screenWidth < 420) {
      titleSize = titleSize.clamp(11.5, 13.0);
    } else if (screenWidth < 480) {
      titleSize = titleSize.clamp(12.0, 14.0);
    } else if (screenWidth < 600) {
      titleSize = titleSize.clamp(13.5, 16.5);
    } else if (screenWidth < 900) {
      titleSize = titleSize.clamp(17.0, 21.0);
    } else if (screenWidth < 1200) {
      titleSize = titleSize.clamp(20.0, 24.0);
    }

    final accentBump = screenWidth < 420 ? 1.0 : screenWidth < 900 ? 2.5 : 4.0;
    final accentSize = titleSize + accentBump;
    final subSize = (titleSize * 0.7).clamp(9.0, 13.5);
    final ctaSize = (titleSize * 0.78).clamp(10.0, 14.5);
    final verticalPad = screenWidth < 420 ? 8.0 : screenWidth < 600 ? 10.0 : 20.0;

    return _PromoCopyTypography(
      titleSize: titleSize,
      accentSize: accentSize,
      subSize: subSize,
      ctaSize: ctaSize,
      horizontalPad: pad,
      verticalPad: verticalPad,
      ctaHPadding: screenWidth < 420 ? 14.0 : screenWidth < 600 ? 16.0 : 26.0,
      ctaVPadding: screenWidth < 420 ? 6.0 : screenWidth < 600 ? 7.0 : 11.0,
      ctaRadius: screenWidth < 420 ? 18.0 : 24.0,
      plantSize: screenWidth < 420 ? 56.0 : screenWidth < 600 ? 72.0 : 110.0,
      subMaxLines: 3,
      gapAfterTitle: screenWidth < 420 ? 4.0 : screenWidth < 600 ? 6.0 : 12.0,
      gapBeforeCta: screenWidth < 420 ? 8.0 : screenWidth < 600 ? 10.0 : 16.0,
    );
  }
}

class _HomePromoMosaicGrid extends StatelessWidget {
  const _HomePromoMosaicGrid({
    required this.tiles,
    required this.isDark,
    required this.gap,
    required this.skewFactor,
  });

  final List<_HomePromoMosaicTile> tiles;
  final bool isDark;
  final double gap;
  final double skewFactor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          if (w <= 0 || h <= 0) return const SizedBox.shrink();

          return ClipRect(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..setEntry(0, 1, -skewFactor),
              child: SizedBox(
                width: w * 1.08,
                height: h,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: gap,
                    vertical: gap,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            for (var col = 0; col < 3; col++)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: col == 2 ? 0 : gap,
                                  ),
                                  child: _HomePromoMosaicCell(
                                    tile: tiles[col],
                                    isDark: isDark,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: gap),
                      Expanded(
                        child: Row(
                          children: [
                            for (var col = 0; col < 3; col++)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: col == 2 ? 0 : gap,
                                  ),
                                  child: _HomePromoMosaicCell(
                                    tile: tiles[3 + col],
                                    isDark: isDark,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomePromoMosaicCell extends StatelessWidget {
  const _HomePromoMosaicCell({
    required this.tile,
    required this.isDark,
  });

  final _HomePromoMosaicTile tile;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final fallbackColor = isDark
        ? AppColors.darkSurfaceContainerHigh
        : AppColors.lightSurfaceContainer;

    Widget fallback() {
      return ColoredBox(
        color: fallbackColor,
        child: Center(
          child: Icon(
            tile.icon,
            size: 26,
            color: AppColors.brandBrown.withValues(alpha: 0.75),
          ),
        ),
      );
    }

    return ClipRect(
      child: SizedBox.expand(
        child: AppNetworkImage(
          url: tile.url,
          fit: BoxFit.cover,
          alignment: tile.alignment,
          placeholder: fallback(),
          error: fallback(),
        ),
      ),
    );
  }
}

class _DiagonalPanelClipper extends CustomClipper<Path> {
  const _DiagonalPanelClipper({required this.bottomInset});

  final double bottomInset;

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(bottomInset, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant _DiagonalPanelClipper oldClipper) {
    return oldClipper.bottomInset != bottomInset;
  }
}

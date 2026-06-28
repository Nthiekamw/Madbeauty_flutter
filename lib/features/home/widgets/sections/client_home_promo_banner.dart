import 'package:flutter/material.dart';

import '../../../../router/navigation_extensions.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/theme/app_colors.dart';

/// Bannière hero accueil : pleine largeur, image rognée (texte dans l'asset).
class ClientHomePromoBanner extends StatelessWidget {
  const ClientHomePromoBanner({super.key});

  static const _bannerAsset = 'assets/images/home_promo_banner.png';

  /// Fond beige de l'asset (harmonise les bords si léger rognage).
  static const _bannerLetterbox = Color(0xFFF3E8DC);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final layout = DiscoveryResponsive.of(context);
    final pad = layout.horizontalPadding;

    return Transform.translate(
      offset: Offset(-pad, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dims = layout.homePromoBannerDimensions(
            constraints.maxWidth,
            horizontalPadding: pad,
          );

          return Material(
            color: AppColors.transparent,
            clipBehavior: Clip.antiAlias,
            elevation: isDark ? 0 : 1,
            shadowColor: AppColors.brandBrown.withValues(alpha: 0.12),
            child: InkWell(
              onTap: () => context.goClientSearch(),
              child: Ink(
                width: dims.width,
                height: dims.height,
                decoration: const BoxDecoration(color: _bannerLetterbox),
                child: Image.asset(
                  _bannerAsset,
                  fit: BoxFit.cover,
                  width: dims.width,
                  height: dims.height,
                  alignment: const Alignment(-0.12, 0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

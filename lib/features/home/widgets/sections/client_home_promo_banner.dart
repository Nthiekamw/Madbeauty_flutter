import 'package:flutter/material.dart';

import '../../../../router/navigation_extensions.dart';
import '../../../../shared/theme/app_colors.dart';

/// Bannière hero accueil : image seule (texte inclus dans l'asset).
class ClientHomePromoBanner extends StatelessWidget {
  const ClientHomePromoBanner({super.key});

  static const _bannerAsset = 'assets/images/home_promo_banner.png';
  static const _bannerHeight = 188.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: AppColors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      elevation: isDark ? 0 : 1,
      shadowColor: AppColors.brandBrown.withValues(alpha: 0.14),
      child: InkWell(
        onTap: () => context.goClientSearch(),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: _bannerHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.08),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              _bannerAsset,
              fit: BoxFit.cover,
              width: double.infinity,
              height: _bannerHeight,
            ),
          ),
        ),
      ),
    );
  }
}

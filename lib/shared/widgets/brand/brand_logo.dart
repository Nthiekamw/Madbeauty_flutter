import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';

/// Logo MadBeauty (asset) avec option tagline et halo doré.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.width = 240,
    this.showTagline = false,
    this.tagline,
    this.showGlow = true,
    this.glowColor,
    this.glowBlurRadius = 32,
    this.glowSpreadRadius = 4,
    this.caption,
    this.captionStyle,
  });

  final double width;
  final bool showTagline;
  final String? tagline;
  final bool showGlow;
  final Color? glowColor;
  final double glowBlurRadius;
  final double glowSpreadRadius;
  final String? caption;
  final TextStyle? captionStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final captionText = caption ??
        (showTagline ? (tagline ?? CoreStrings.tagline) : null);
    final captionColor =
        captionStyle?.color ?? theme.colorScheme.onSurfaceVariant;

    final logo = Image.asset(
      AppAssets.logo,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => Icon(
        Icons.spa_outlined,
        size: width * 0.28,
        color: AppColors.brandGold,
      ),
    );

    Widget mark = logo;
    if (showGlow) {
      mark = DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: glowColor ?? AppColors.brandGoldGlow20,
              blurRadius: glowBlurRadius,
              spreadRadius: glowSpreadRadius,
            ),
          ],
        ),
        child: logo,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        if (captionText != null && captionText.isNotEmpty) ...[
          SizedBox(height: width < 200 ? 10 : 16),
          Text(
            captionText,
            textAlign: TextAlign.center,
            style: captionStyle ??
                theme.textTheme.bodySmall?.copyWith(
                  fontFamily: AppFonts.body,
                  color: captionColor,
                  height: 1.4,
                  letterSpacing: 0.15,
                ),
          ),
        ],
      ],
    );
  }
}

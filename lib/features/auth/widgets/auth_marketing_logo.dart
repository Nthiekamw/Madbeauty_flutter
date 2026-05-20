import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';

/// Logo MadBeauty pour écrans marketing (onboarding, bienvenue).
class AuthMarketingLogo extends StatelessWidget {
  const AuthMarketingLogo({super.key, this.width = 240});

  final double width;

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppAssets.logo,
          width: width,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => Icon(
            Icons.spa_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          CoreStrings.tagline,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: AppFonts.body,
                color: onSurfaceVariant,
                height: 1.4,
              ),
        ),
      ],
    );
  }
}

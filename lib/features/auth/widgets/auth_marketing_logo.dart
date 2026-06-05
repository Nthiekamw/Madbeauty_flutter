import 'package:flutter/material.dart';

import '../../../shared/widgets/brand/brand_logo.dart';

/// Logo MadBeauty pour écrans marketing (onboarding, bienvenue, auth).
class AuthMarketingLogo extends StatelessWidget {
  const AuthMarketingLogo({super.key, this.width = 240});

  final double width;

  @override
  Widget build(BuildContext context) {
    return BrandLogo(
      width: width,
      showTagline: true,
      showGlow: true,
    );
  }
}

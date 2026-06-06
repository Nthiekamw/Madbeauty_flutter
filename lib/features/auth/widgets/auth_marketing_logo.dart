import 'package:flutter/material.dart';

import '../../../shared/widgets/brand/brand_logo.dart';

/// Logo MadBeauty pour écrans marketing (onboarding, bienvenue, auth).
class AuthMarketingLogo extends StatelessWidget {
  const AuthMarketingLogo({
    super.key,
    this.width = 240,
    this.showTagline = true,
  });

  final double width;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return BrandLogo(
      width: width,
      showTagline: showTagline,
      showGlow: true,
    );
  }
}

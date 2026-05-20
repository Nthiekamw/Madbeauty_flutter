import 'package:flutter/material.dart';

import '../../../shared/widgets/brand_background.dart';

/// Fond splash — délègue à [BrandBackground].
class SplashBrandBackground extends StatelessWidget {
  const SplashBrandBackground({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) => BrandBackground(isDark: isDark);
}

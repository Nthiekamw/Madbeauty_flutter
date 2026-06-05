import 'package:flutter/material.dart';

/// Logo Google officiel (asset `assets/images/google_logo.png`).
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 24});

  final double size;

  static const _assetPath = 'assets/images/google_logo.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => Icon(
        Icons.g_mobiledata_rounded,
        size: size,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}


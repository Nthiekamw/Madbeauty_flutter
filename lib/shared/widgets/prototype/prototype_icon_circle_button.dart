import 'package:flutter/material.dart';

import '../../theme/prototype_palette.dart';

/// Bouton rond blanc (paramètres, cloche) — accueil client.
class PrototypeIconCircleButton extends StatelessWidget {
  const PrototypeIconCircleButton({
    super.key,
    required this.icon,
    required this.size,
    this.onTap,
    this.showNotificationDot = false,
  });

  final IconData icon;
  final double size;
  final VoidCallback? onTap;
  final bool showNotificationDot;

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.5;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: PrototypePalette.cardWhite,
              shape: BoxShape.circle,
              boxShadow: PrototypePalette.cardShadow(opacity: 0.08),
            ),
            child: Icon(icon, size: iconSize, color: PrototypePalette.textMed),
          ),
          if (showNotificationDot)
            Positioned(
              top: size * 0.05,
              right: size * 0.05,
              child: Container(
                width: size * 0.22,
                height: size * 0.22,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Onglet d'une barre de navigation shell (mobile ou rail web).
class ShellNavDestination {
  const ShellNavDestination({
    required this.label,
    required this.outlinedIcon,
    required this.filledIcon,
    this.badgeCount = 0,
  });

  final String label;
  final IconData outlinedIcon;
  final IconData filledIcon;
  final int badgeCount;
}

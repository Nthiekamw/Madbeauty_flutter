import 'package:flutter/material.dart';

import '../../../../shared/widgets/discovery/content/discovery_section_header.dart';

/// En-tête de section prestataire (aligné accueil).
class PrestataireSectionHeader extends StatelessWidget {
  const PrestataireSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.badgeCount,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final int? badgeCount;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return DiscoverySectionHeader(
      icon: icon,
      title: title,
      subtitle: subtitle,
      badgeCount: badgeCount,
      iconColor: iconColor,
      compact: true,
      showSubtitleWhenCompact: true,
    );
  }
}

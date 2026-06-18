import 'package:flutter/material.dart';

import '../../../../shared/widgets/discovery/content/discovery_section_header.dart';

/// Titre de section accueil + action optionnelle.
class ClientHomeSectionHeader extends StatelessWidget {
  const ClientHomeSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return DiscoverySectionHeader(
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
      compact: compact,
      icon: icon,
      iconColor: iconColor,
    );
  }
}

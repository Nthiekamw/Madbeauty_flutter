import 'package:flutter/material.dart';

import '../../../../shared/widgets/discovery/content/discovery_section_header.dart';

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DiscoverySectionHeader(
        title: title,
        subtitle: subtitle,
        icon: icon,
        compact: true,
      ),
    );
  }
}

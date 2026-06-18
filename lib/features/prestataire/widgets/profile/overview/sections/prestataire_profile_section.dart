import 'package:flutter/material.dart';

import '../../../../../../../shared/widgets/discovery/content/discovery_section_header.dart';
import '../layout/prestataire_profile_insets.dart';

/// Bloc de page profil : titre de section + contenu aligné sur les marges.
class PrestataireProfileSection extends StatelessWidget {
  const PrestataireProfileSection({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.topGap = PrestataireProfileInsets.sectionTop,
  });

  final String title;
  final List<Widget> children;
  final IconData? icon;
  final double topGap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: PrestataireProfileInsets.page(context).copyWith(top: topGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DiscoverySectionHeader(
            title: title,
            icon: icon ?? Icons.work_outline_rounded,
            compact: true,
            padding: const EdgeInsets.only(bottom: 8),
          ),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: PrestataireProfileInsets.itemGap),
            children[i],
          ],
        ],
      ),
    );
  }
}

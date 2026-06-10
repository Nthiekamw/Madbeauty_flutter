import 'package:flutter/material.dart';

import '../../../../../../../shared/theme/app_fonts.dart';
import '../layout/prestataire_profile_insets.dart';

/// Bloc de page profil : titre de section + contenu aligné sur les marges.
class PrestataireProfileSection extends StatelessWidget {
  const PrestataireProfileSection({
    super.key,
    required this.title,
    required this.children,
    this.topGap = PrestataireProfileInsets.sectionTop,
  });

  final String title;
  final List<Widget> children;
  final double topGap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: PrestataireProfileInsets.page(context).copyWith(top: topGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: PrestataireProfileInsets.titleBottom),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: PrestataireProfileInsets.itemGap),
            children[i],
          ],
        ],
      ),
    );
  }
}

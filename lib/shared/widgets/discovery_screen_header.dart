import 'package:flutter/material.dart';

import '../theme/app_fonts.dart';
import '../theme/prototype_layout.dart';
import '../theme/prototype_palette.dart';
import 'prototype/prototype_white_header_bar.dart';

/// En-tête des écrans client (accueil, recherche, réservations, profil).
class DiscoveryScreenHeader extends StatelessWidget {
  const DiscoveryScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.whiteBar = false,
  });

  final String title;
  final String? subtitle;

  /// Bandeau blanc pleine largeur (style recherche / RDV Madbeauty_flutter).
  final bool whiteBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layout = PrototypeLayout(context);
    final isDark = theme.brightness == Brightness.dark;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.1,
            color: isDark ? null : PrototypePalette.textDark,
            fontSize: whiteBar ? layout.sp(5) : null,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: layout.sp(0.8)),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: AppFonts.body,
              color: isDark
                  ? theme.colorScheme.onSurfaceVariant
                  : PrototypePalette.textGrey,
              height: 1.4,
              fontSize: whiteBar ? layout.sp(3.2) : null,
            ),
          ),
        ],
      ],
    );

    if (whiteBar && !isDark) {
      return PrototypeWhiteHeaderBar(child: content);
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(layout.sp(4), layout.sp(2), layout.sp(4), 0),
      child: content,
    );
  }
}

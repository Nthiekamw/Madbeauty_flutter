import 'package:flutter/material.dart';

import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_fonts.dart';

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hPad = DiscoveryResponsive.of(context).horizontalPadding;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 10),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontFamily: AppFonts.display,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

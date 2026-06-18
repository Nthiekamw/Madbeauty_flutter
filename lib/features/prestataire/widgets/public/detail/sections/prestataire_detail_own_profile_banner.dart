import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../../shared/theme/app_fonts.dart';
import 'prestataire_detail_surface.dart';

class PrestataireDetailOwnProfileBanner extends StatelessWidget {
  const PrestataireDetailOwnProfileBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = DiscoveryResponsive.of(context).horizontalPadding;
    final secondary = theme.colorScheme.secondary;

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 18, pad, 0),
      child: PrestataireDetailSurface.cardMaterial(
        theme: theme,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: secondary,
                size: 17,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                DiscPrestaDetail.ownProfileBookHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  height: 1.4,
                  fontFamily: AppFonts.body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

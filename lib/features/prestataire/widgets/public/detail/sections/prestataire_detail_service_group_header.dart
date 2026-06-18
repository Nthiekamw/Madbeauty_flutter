import 'package:flutter/material.dart';

import '../../../../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../../../../shared/theme/app_fonts.dart';

class PrestataireDetailServiceGroupHeader extends StatelessWidget {
  const PrestataireDetailServiceGroupHeader({
    super.key,
    required this.title,
    this.main,
    this.compact = false,
  });

  final String title;
  final PrestaMainService? main;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final icon = main != null
        ? PrestataireServiceCatalog.icon(main!)
        : Icons.spa_outlined;

    return Padding(
      padding: EdgeInsets.only(
        top: compact ? 2 : 8,
        bottom: compact ? 6 : 8,
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 28 : 32,
            height: compact ? 28 : 32,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(compact ? 9 : 10),
            ),
            child: Icon(icon, size: compact ? 15 : 17, color: primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w800,
                fontSize: compact ? 12 : 13,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

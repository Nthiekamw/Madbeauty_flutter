import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/widgets/discovery/discovery_surface_card.dart';

/// Infos « accès catalogue » en bas de l’écran Accès catalogue.
class PrestataireSubscriptionTestimonialsSection extends StatelessWidget {
  const PrestataireSubscriptionTestimonialsSection({super.key});

  static final _items = [
    (
      icon: Icons.visibility_rounded,
      title: DiscPrestaSub.catalogHelpVisibilityTitle,
      body: DiscPrestaSub.catalogHelpVisibilityBody,
    ),
    (
      icon: Icons.event_available_rounded,
      title: DiscPrestaSub.catalogHelpBookingTitle,
      body: DiscPrestaSub.catalogHelpBookingBody,
    ),
    (
      icon: Icons.card_giftcard_rounded,
      title: DiscPrestaSub.catalogHelpTrialTitle,
      body: DiscPrestaSub.catalogHelpTrialBody,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hPad = DiscoveryResponsive.of(context).horizontalPadding;
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            DiscPrestaSub.catalogHelpTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _CatalogHelpCard(
              icon: _items[i].icon,
              iconColor: primary,
              title: _items[i].title,
              body: _items[i].body,
            ),
          ],
        ],
      ),
    );
  }
}

class _CatalogHelpCard extends StatelessWidget {
  const _CatalogHelpCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      includeHorizontalMargin: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: AppFonts.body,
                    height: 1.45,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

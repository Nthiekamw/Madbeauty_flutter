import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/widgets/discovery/discovery_surface_card.dart';

/// Témoignages coiffeurs Pro en bas de l’écran « Mon abonnement ».
class PrestataireSubscriptionTestimonialsSection extends StatelessWidget {
  const PrestataireSubscriptionTestimonialsSection({super.key});

  static final _items = [
    (
      quote: DiscPrestaSub.testimonialSophieQuote,
      author: DiscPrestaSub.testimonialSophieAuthor,
    ),
    (
      quote: DiscPrestaSub.testimonialMarcQuote,
      author: DiscPrestaSub.testimonialMarcAuthor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hPad = DiscoveryResponsive.of(context).horizontalPadding;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            DiscPrestaSub.testimonialsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _TestimonialCard(
              quote: _items[i].quote,
              author: _items[i].author,
            ),
          ],
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({
    required this.quote,
    required this.author,
  });

  final String quote;
  final String author;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      includeHorizontalMargin: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FiveStarRating(),
          const SizedBox(height: 10),
          Text(
            quote,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: AppFonts.body,
              height: 1.45,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '— $author',
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: AppFonts.body,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _FiveStarRating extends StatelessWidget {
  const _FiveStarRating();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (_) => const Padding(
          padding: EdgeInsets.only(right: 2),
          child: Icon(
            Icons.star_rounded,
            size: 18,
            color: AppColors.brandGold,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/models/domain/reviews/avis.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/theme/app_colors.dart';

/// Liste d'avis clients (fiche publique).
class PrestatairePublicReviewsSection extends StatelessWidget {
  const PrestatairePublicReviewsSection({
    super.key,
    required this.reviews,
  });

  final List<Avis> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return _ReviewsEmptyCard();
    }

    return Column(
      children: [
        for (var i = 0; i < reviews.length; i++) ...[
          _ReviewCard(review: reviews[i]),
          if (i < reviews.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ReviewsEmptyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.rate_review_outlined,
              size: 22,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DiscPrestaDetail.noReviewsTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DiscPrestaDetail.noReviewsBody,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
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

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Avis review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comment = review.commentaire?.trim() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StarRating(note: review.note),
              const Spacer(),
              Text(
                DiscPrestaDetail.reviewDate(review.createdAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              comment,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: AppFonts.body,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.note});

  final int note;

  @override
  Widget build(BuildContext context) {
    final clamped = note.clamp(1, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= clamped ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 18,
            color: AppColors.starRating,
          ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/models/domain/reviews/avis.dart';
import '../../../../../core/models/domain/reviews/review.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../reviews/providers/review_provider.dart';
import '../../../../reviews/widgets/review_photos_row.dart';
import 'prestataire_public_reviews_section.dart';
import '../../../../../shared/theme/app_colors.dart';

/// Liste d'avis avec rechargement après nouvelle note.
class PrestatairePublicReviewsLiveSection extends ConsumerWidget {
  const PrestatairePublicReviewsLiveSection({
    super.key,
    required this.prestataireId,
    this.readOnly = false,
    this.onReviewTap,
  });

  final String prestataireId;
  final bool readOnly;
  final void Function(Review review)? onReviewTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsByPrestataireProvider(prestataireId));

    return reviewsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => PrestatairePublicReviewsSection(reviews: const []),
      data: (reviews) {
        final avis = [
          for (final r in reviews)
            Avis(
              id: r.id,
              clientId: r.clientId,
              prestataireId: r.prestataireId,
              reservationId: r.bookingId,
              note: r.note,
              commentaire: r.commentaire,
              photoUrls: r.photoUrls,
              createdAt: r.createdAt,
            ),
        ];
        if (avis.isEmpty) {
          return const PrestatairePublicReviewsSection(reviews: []);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < reviews.length; i++) ...[
              _LiveReviewCard(
                review: avis[i],
                readOnly: readOnly,
                onTap: onReviewTap == null
                    ? null
                    : () => onReviewTap!(reviews[i]),
              ),
              if (i < avis.length - 1) const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _LiveReviewCard extends StatelessWidget {
  const _LiveReviewCard({
    required this.review,
    this.readOnly = false,
    this.onTap,
  });

  final Avis review;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comment = review.commentaire?.trim() ?? '';

    final card = Container(
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
              _StarRow(note: review.note),
              const Spacer(),
              Text(
                DateFormat('d MMM yyyy', 'fr_FR').format(
                  review.createdAt.toLocal(),
                ),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
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
          if (review.photoUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            ReviewPhotosRow(urls: review.photoUrls),
          ],
          if (readOnly && onTap != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  DiscReview.prestataireViewOnlyHint,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: card,
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.note});

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


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/domain/reviews/avis.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../reviews/providers/review_provider.dart';
import '../../../reviews/widgets/review_photos_row.dart';
import 'prestataire_public_reviews_section.dart';

/// Liste d’avis avec rechargement après nouvelle note.
class PrestatairePublicReviewsLiveSection extends ConsumerWidget {
  const PrestatairePublicReviewsLiveSection({
    super.key,
    required this.prestataireId,
  });

  final String prestataireId;

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
            for (var i = 0; i < avis.length; i++) ...[
              _LiveReviewCard(review: avis[i]),
              if (i < avis.length - 1) const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _LiveReviewCard extends StatelessWidget {
  const _LiveReviewCard({required this.review});

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
        ],
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
            color: const Color(0xFFF59E0B),
          ),
      ],
    );
  }
}

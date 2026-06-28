import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/reviews/review.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../reviews/models/client_review_list_item.dart';
import '../../reviews/widgets/edit_review_sheet.dart';
import '../providers/profile/current_prestataire_provider.dart';
import '../widgets/public/prestataire_public_reviews_live_section.dart';
import '../widgets/workspace/prestataire_flow_scaffold.dart';

/// Avis reçus sur l’activité prestataire — consultation uniquement.
class PrestataireReceivedReviewsScreen extends ConsumerWidget {
  const PrestataireReceivedReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prestaAsync = ref.watch(currentPrestataireProvider);
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;

    return prestaAsync.when(
      loading: () => PrestataireSubpageScaffold(
        title: DiscReview.receivedReviewsTitle,
        subtitle: DiscReview.receivedReviewsSubtitle,
        icon: Icons.rate_review_outlined,
        wrapPanel: false,
        body: const DiscoveryListSkeleton(rowCount: 4, rowHeight: 88),
      ),
      error: (_, __) => PrestataireSubpageScaffold(
        title: DiscReview.receivedReviewsTitle,
        subtitle: DiscReview.receivedReviewsSubtitle,
        icon: Icons.rate_review_outlined,
        wrapPanel: false,
        body: Center(
          child: DiscoveryEmptyState(
            icon: Icons.cloud_off_outlined,
            title: CoreStrings.networkErrorTitle,
            body: CoreStrings.networkErrorBody,
            actionLabel: DiscList.retry,
            onAction: () => ref.invalidate(currentPrestataireProvider),
          ),
        ),
      ),
      data: (presta) {
        if (presta == null) {
          return PrestataireSubpageScaffold(
            title: DiscReview.receivedReviewsTitle,
            subtitle: DiscReview.receivedReviewsSubtitle,
            icon: Icons.rate_review_outlined,
            wrapPanel: false,
            body: const Center(child: Text(DiscPrestaProfile.incompleteBody)),
          );
        }

        return PrestataireSubpageScaffold(
          title: DiscReview.receivedReviewsTitle,
          subtitle: DiscReview.receivedReviewsSubtitle,
          icon: Icons.rate_review_outlined,
          body: ListView(
            padding: useWeb
                ? const EdgeInsets.fromLTRB(20, 16, 20, 24)
                : const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              PrestatairePublicReviewsLiveSection(
                prestataireId: presta.id,
                onReviewTap: (review) => _openReview(context, review),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openReview(BuildContext context, Review review) {
    showViewReviewSheet(
      context,
      item: ClientReviewListItem(review: review),
    );
  }
}

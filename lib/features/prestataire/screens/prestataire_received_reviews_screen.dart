import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/reviews/review.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_feature_header.dart';
import '../../reviews/models/client_review_list_item.dart';
import '../../reviews/widgets/edit_review_sheet.dart';
import '../providers/profile/current_prestataire_provider.dart';
import '../widgets/public/prestataire_public_reviews_live_section.dart';
import '../widgets/workspace/prestataire_brand_scaffold.dart';
import '../widgets/workspace/prestataire_workspace_shell.dart';

/// Avis reçus sur l’activité prestataire — consultation uniquement.
class PrestataireReceivedReviewsScreen extends ConsumerWidget {
  const PrestataireReceivedReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prestaAsync = ref.watch(currentPrestataireProvider);

    return PrestataireBrandScaffold(
      body: prestaAsync.when(
        loading: () => const PrestataireWorkspaceShell(
          child: DiscoveryListSkeleton(rowCount: 4, rowHeight: 88),
        ),
        error: (_, __) => PrestataireWorkspaceShell(
          onRefresh: () async {
            ref.invalidate(currentPrestataireProvider);
          },
          child: Center(
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
            return const PrestataireWorkspaceShell(
              child: Center(child: Text(DiscPrestaProfile.incompleteBody)),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              const DiscoveryFeatureHeader(
                title: DiscReview.receivedReviewsTitle,
                subtitle: DiscReview.receivedReviewsSubtitle,
                icon: Icons.rate_review_outlined,
              ),
              Expanded(
                child: PrestatairePublicReviewsLiveSection(
                  prestataireId: presta.id,
                  onReviewTap: (review) => _openReview(context, review),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openReview(BuildContext context, Review review) {
    showViewReviewSheet(
      context,
      item: ClientReviewListItem(review: review),
    );
  }
}
